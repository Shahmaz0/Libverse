import SwiftUI
import CommonCrypto

// Image Cache
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private let userDefaultsKey = "cachedImageURLs"
    
    private init() {
        // Set cache limits (adjust these based on your app's memory requirements)
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        // Register for app termination notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveURLsToUserDefaults),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
        
        // Load cached URLs 
        loadCachedURLs()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getImage(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
        // Save to persistent cache
        saveImageToDisk(image, for: key)
    }
    
    func removeImage(for key: String) {
        cache.removeObject(forKey: key as NSString)
        // Remove from persistent cache
        removeImageFromDisk(for: key)
    }
    
    func clearCache() {
        cache.removeAllObjects()
        // Clear the persistent cache
        let fileManager = FileManager.default
        guard let cacheURL = getCacheDirectoryURL() else { return }
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            print("Error clearing disk cache: \(error)")
        }
    }
    
    // MARK: - Disk Cache Methods
    
    private func getCacheDirectoryURL() -> URL? {
        let fileManager = FileManager.default
        guard let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let cacheDirectoryURL = cachesDirectory.appendingPathComponent("ImageCache")
        
        if !fileManager.fileExists(atPath: cacheDirectoryURL.path) {
            do {
                try fileManager.createDirectory(at: cacheDirectoryURL, withIntermediateDirectories: true)
            } catch {
                print("Error creating cache directory: \(error)")
                return nil
            }
        }
        
        return cacheDirectoryURL
    }
    
    private func saveImageToDisk(_ image: UIImage, for key: String) {
        guard let data = image.jpegData(compressionQuality: 0.8),
              let cacheURL = getCacheDirectoryURL() else {
            return
        }
        
        let fileURL = cacheURL.appendingPathComponent(key.md5())
        
        do {
            try data.write(to: fileURL)
            // Save URL to UserDefaults for later retrieval
            saveURLToUserDefaults(key)
        } catch {
            print("Error saving image to disk: \(error)")
        }
    }
    
    private func removeImageFromDisk(for key: String) {
        guard let cacheURL = getCacheDirectoryURL() else { return }
        let fileURL = cacheURL.appendingPathComponent(key.md5())
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            removeURLFromUserDefaults(key)
        } catch {
            print("Error removing image from disk: \(error)")
        }
    }
    
    private func loadImageFromDisk(for key: String) -> UIImage? {
        guard let cacheURL = getCacheDirectoryURL() else { return nil }
        let fileURL = cacheURL.appendingPathComponent(key.md5())
        
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    // MARK: - UserDefaults Methods
    
    private func saveURLToUserDefaults(_ key: String) {
        var cachedURLs = UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? []
        if !cachedURLs.contains(key) {
            cachedURLs.append(key)
            UserDefaults.standard.set(cachedURLs, forKey: userDefaultsKey)
        }
    }
    
    private func removeURLFromUserDefaults(_ key: String) {
        var cachedURLs = UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? []
        cachedURLs.removeAll { $0 == key }
        UserDefaults.standard.set(cachedURLs, forKey: userDefaultsKey)
    }
    
    @objc public func saveURLsToUserDefaults() {
        // This will be called when the app is about to terminate
        // We'll make sure UserDefaults has all cached URLs
        let cachedKeys = NSMutableArray()
        
        // Create a custom method to get all keys since NSCache doesn't expose them
        // We rely on our tracked URLs in UserDefaults 
        let defaults = UserDefaults.standard
        let cachedURLs = defaults.stringArray(forKey: userDefaultsKey) ?? []
        
        // Check if each URL still has a valid image in the cache
        for url in cachedURLs {
            if cache.object(forKey: url as NSString) != nil {
                cachedKeys.add(url)
            }
        }
        
        defaults.set(cachedKeys as NSArray as? [String], forKey: userDefaultsKey)
    }
    
    private func loadCachedURLs() {
        let cachedURLs = UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? []
        
        for key in cachedURLs {
            if let image = loadImageFromDisk(for: key) {
                cache.setObject(image, forKey: key as NSString)
            }
        }
    }
}

// MD5 hash extension for generating unique filenames
extension String {
    func md5() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = data.withUnsafeBytes {
            CC_MD5($0.baseAddress, CC_LONG(data.count), &digest)
        }
        
        var hashString = ""
        for byte in digest {
            hashString += String(format: "%02x", byte)
        }
        
        return hashString
    }
}

// Create a cached async image view
struct CachedAsyncImage: View {
    let url: URL?
    
    init(url: URL?) {
        self.url = url
    }
    
    var body: some View {
        Group {
            if let url = url, let cachedImage = ImageCache.shared.getImage(for: url.absoluteString) {
                Image(uiImage: cachedImage)
                    .resizable()
                    .scaledToFill()
            } else {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .onAppear {
                                if let url = url {
                                    #if os(iOS)
                                    // Use a direct caching approach
                                    if let uiImage = saveImageToCache(image: image, url: url.absoluteString) {
                                        // Image was successfully cached
                                    }
                                    #endif
                                }
                            }
                    case .failure:
                        // Error view
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.red)
                            .frame(width: 30, height: 30)
                    case .empty:
                        // Loading view
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
    }
    
    // Helper function to cache the image
    private func saveImageToCache(image: Image, url: String) -> UIImage? {
        // Try to convert the SwiftUI Image to UIImage
        let uiImage: UIImage?
        
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: image.resizable().scaledToFill())
            uiImage = renderer.uiImage
        } else {
            // Fallback for older iOS
            let controller = UIHostingController(rootView: image.resizable().scaledToFill())
            controller.view.frame = CGRect(x: 0, y: 0, width: 93, height: 120)
            controller.view.backgroundColor = .clear
            
            let renderer = UIGraphicsImageRenderer(size: controller.view.bounds.size)
            uiImage = renderer.image { _ in
                controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            }
        }
        
        // Cache the image if conversion was successful
        if let uiImage = uiImage {
            ImageCache.shared.setImage(uiImage, for: url)
            return uiImage
        }
        
        return nil
    }
}

// Extension to convert SwiftUI Image to UIImage
extension Image {
    @MainActor func asUIImage() -> UIImage {
        // Use this approach for iOS 16+
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: self.resizable().scaledToFill())
            if let uiImage = renderer.uiImage {
                return uiImage
            }
        }
        
        // Fallback for older iOS versions or if the ImageRenderer fails
        let controller = UIHostingController(rootView: self.resizable().scaledToFill())
        controller.view.frame = CGRect(x: 0, y: 0, width: 93, height: 120)
        
        // Make sure the background is clear
        controller.view.backgroundColor = .clear
        
        // Create UIImage from the controller's view
        let renderer = UIGraphicsImageRenderer(size: controller.view.bounds.size)
        let image = renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        
        return image
    }
} 
