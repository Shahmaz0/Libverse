import Foundation
import NaturalLanguage

class TranslationManager {
    static let shared = TranslationManager()
    
    private init() {}
    
    // Cache to store previously translated texts to avoid redundant API calls
    private var translationCache = [String: String]()
    
    /// Translates text from one language to another
    /// - Parameters:
    ///   - text: The text to translate
    ///   - sourceLanguage: The source language code (e.g., "en" for English)
    ///   - targetLanguage: The target language code (e.g., "hi" for Hindi)
    ///   - completion: A closure that gets called with the result
    func translateText(_ text: String, from sourceLanguage: String, to targetLanguage: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Generate a cache key using source text and target language
        let cacheKey = "\(text)_\(targetLanguage)"
        
        // Check if we have a cached translation
        if let cachedTranslation = translationCache[cacheKey] {
            completion(.success(cachedTranslation))
            return
        }
        
        // For iOS 16 and later, we can use the built-in translation API
        // For earlier versions, we'll use a network-based translation service
        
        // Since iOS 16+ API might not be available, we'll use a network service
        translateUsingNetworkService(text, from: sourceLanguage, to: targetLanguage) { [weak self] result in
            if case .success(let translatedText) = result {
                // Cache the result
                self?.translationCache[cacheKey] = translatedText
            }
            completion(result)
        }
    }
    
    private func translateUsingNetworkService(_ text: String, from sourceLanguage: String, to targetLanguage: String, completion: @escaping (Result<String, Error>) -> Void) {
        // For demonstration purposes, we'll use a free translation API
        // In a production app, you would use a more reliable service like Google Cloud Translation API
        
        // For safety, URL encode the text
        guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(NSError(domain: "TranslationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode text"])))
            return
        }
        
        let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=\(sourceLanguage)&tl=\(targetLanguage)&dt=t&q=\(encodedText)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "TranslationError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "TranslationError", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                // The response is a complex JSON array format, parse it to extract the translation
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [Any],
                   let textArray = jsonArray[0] as? [Any] {
                    
                    var translatedText = ""
                    
                    // Concatenate all translated parts
                    for item in textArray {
                        if let itemArray = item as? [Any], let text = itemArray[0] as? String {
                            translatedText += text
                        }
                    }
                    
                    if !translatedText.isEmpty {
                        completion(.success(translatedText))
                    } else {
                        completion(.failure(NSError(domain: "TranslationError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to parse translation"])))
                    }
                } else {
                    completion(.failure(NSError(domain: "TranslationError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Alternative implementation using on-device translation (iOS 15+)
    
    // This is an alternative implementation that uses on-device translation
    // for iOS versions that support it. For a production app, you might want to
    // conditionally use this method when available.
    
    private func translateUsingOnDeviceAPI(_ text: String, from sourceLanguage: String, to targetLanguage: String, completion: @escaping (Result<String, Error>) -> Void) {
        // For demo purposes, we're skipping this implementation
        // On iOS 15+, you would use NLTranslator with a code like:
        
        /*
        let translator = NLTranslator(fromLanguage: NLLanguage(rawValue: sourceLanguage), toLanguage: NLLanguage(rawValue: targetLanguage))
        
        translator.translate(text) { translatedText, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let translatedText = translatedText {
                completion(.success(translatedText))
            } else {
                completion(.failure(NSError(domain: "TranslationError", code: 5, userInfo: [NSLocalizedDescriptionKey: "Translation failed"])))
            }
        }
        */
        
        // Since we can't implement this directly without conditionals for iOS version,
        // we'll just use the network service for all translations
        translateUsingNetworkService(text, from: sourceLanguage, to: targetLanguage, completion: completion)
    }
} 