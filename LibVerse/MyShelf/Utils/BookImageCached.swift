//
//  BookImageCached.swift
//  LibVerse
//
//  Created by Piyush on 31/03/25.
//

import Foundation
import SwiftUI

// After RefreshableScrollView, add a custom CachedImage component to be used in myshelf
struct CachedImage: View {
    let url: String
    
    var body: some View {
        if !url.isEmpty {
            if let cachedImage = ImageCache.shared.getImage(for: url) {
                Image(uiImage: cachedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 93, height: 120)
                    .clipped()
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
            } else {
                AsyncImage(url: URL(string: url)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 93, height: 120)
                            .clipped()
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                            .onAppear {
                                // Save to cache using a compatible approach
                                #if os(iOS)
                                // Use a UIKit approach which works on all iOS versions
                                DispatchQueue.global(qos: .background).async {
                                    if let imageURL = URL(string: url), let data = try? Data(contentsOf: imageURL),
                                       let uiImage = UIImage(data: data) {
                                        DispatchQueue.main.async {
                                            ImageCache.shared.setImage(uiImage, for: url)
                                        }
                                    }
                                }
                                #endif
                            }
                    case .failure:
                        ZStack {
                            ShimmerBookCover(opacity: 0.8)
                            
                            // Add a small error indicator
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "DE5B23").opacity(0.8))
                                .offset(y: -40)
                        }
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    case .empty:
                        ShimmerBookCover(opacity: 0.8)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        } else {
            ShimmerBookCover(opacity: 0.8)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
        }
    }
}

// After CachedImage, add a specialized version for BookCards

struct BookCardCachedImage: View {
    let url: String
    
    var body: some View {
        if !url.isEmpty {
            if let cachedImage = ImageCache.shared.getImage(for: url) {
                Image(uiImage: cachedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 60)
                    .clipped()
            } else {
                AsyncImage(url: URL(string: url)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 45, height: 60)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 45, height: 60)
                            .clipped()
                            .onAppear {
                                // Save to cache using a compatible approach
                                #if os(iOS)
                                // Use a UIKit approach which works on all iOS versions
                                DispatchQueue.global(qos: .background).async {
                                    if let imageURL = URL(string: url), let data = try? Data(contentsOf: imageURL),
                                       let uiImage = UIImage(data: data) {
                                        DispatchQueue.main.async {
                                            ImageCache.shared.setImage(uiImage, for: url)
                                        }
                                    }
                                }
                                #endif
                            }
                    case .failure:
                        Image("mvc")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 45, height: 60)
                            .clipped()
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        } else {
            Image("mvc")
                .resizable()
                .scaledToFill()
                .frame(width: 45, height: 60)
                .clipped()
                .background(Color.white)
        }
    }
}
