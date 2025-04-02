//
//  SplashScreen_Shimmer.swift
//  LibVerse
//
//  Created by Piyush on 31/03/25.
//

import Foundation
import SwiftUI


// Splash Screen Animation
struct SplashScreen: View {
    @State private var bookRotation: Double = 0
    @State private var bookScale: CGFloat = 1.0
    @State private var bookOpacity: Double = 0.7
    @State private var textOpacity: Double = 0
    @State private var shimmerOffset: CGFloat = -0.25
    @State private var pageFlipAngle: Double = 0
    @State private var currentPage: Int = 0
    
    var body: some View {
        ZStack {
            Color(hex: "FCEFD5")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    // Book shadow
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 120, height: 160)
                        .offset(x: 5, y: 5)
                    
                    // Book cover and pages
                    ZStack {
                        // Book base
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(hex: "DE5B23"))
                            .frame(width: 120, height: 160)
                        
                        // Book spine detail
                        Rectangle()
                            .fill(Color(hex: "C89A69"))
                            .frame(width: 20, height: 160)
                            .offset(x: -50, y: 0)
                        
                        // Book pages
                        ForEach(0..<5) { index in
                            Rectangle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 100, height: 150)
                                .offset(x: 8)
                                .rotationEffect(.degrees(index == currentPage ? pageFlipAngle : 0), anchor: .leading)
                                .opacity(index > currentPage ? 0 : 1)
                        }
                        
                        // Book title lines
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(0..<3) { _ in
                                Rectangle()
                                    .fill(Color.white.opacity(0.7))
                                    .frame(width: 70, height: 8)
                            }
                        }
                        .offset(x: 10)
                        .opacity(pageFlipAngle > 45 ? 0 : 1)
                        
                        // Shimmer effect
                        RoundedRectangle(cornerRadius: 5)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.0),
                                        Color.white.opacity(0.5),
                                        Color.white.opacity(0.0)
                                    ]),
                                    startPoint: UnitPoint(x: shimmerOffset, y: 0.5),
                                    endPoint: UnitPoint(x: shimmerOffset + 1, y: 0.5)
                                )
                            )
                            .frame(width: 120, height: 160)
                            .blendMode(.screen)
                    }
                    .rotationEffect(.degrees(bookRotation))
                    .scaleEffect(bookScale)
                    .opacity(bookOpacity)
                }
                
                Text("Pustakalaya")
                    .font(.custom("Charter", size: 32))
                    .foregroundColor(Color(hex: "7C4B2D"))
                    .opacity(textOpacity)
                
                Text("Loading your shelves...")
                    .font(.custom("Charter", size: 16))
                    .foregroundColor(Color(hex: "7C4B2D"))
                    .opacity(textOpacity)
            }
        }
        .onAppear {
            // Rotating animation
            withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                bookRotation = 10
                bookScale = 1.1
                bookOpacity = 1.0
            }
            
            // Text fade in
            withAnimation(Animation.easeIn(duration: 0.7).delay(0.3)) {
                textOpacity = 1.0
            }
            
            // Shimmer animation
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 1.25
            }
            
            // Page flip animation
            flipPages()
        }
    }
    
    private func flipPages() {
        // Initial delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            flipPage()
        }
    }
    
    private func flipPage() {
        withAnimation(Animation.easeInOut(duration: 0.6)) {
            pageFlipAngle = 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Reset angle without animation and set up next page
            pageFlipAngle = 0
            currentPage = (currentPage + 1) % 5
            
            // Recursively call flipPage for continuous animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                flipPage()
            }
        }
    }
}

// Shimmer Book Cover View
struct ShimmerBookCover: View {
    @State private var shimmerOffset: CGFloat = -0.25
    var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Book base shape
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3 * opacity))
                .frame(width: 93, height: 120)
            
            // Book spine
            HStack(spacing: 0) {
                // Spine
                Rectangle()
                    .fill(Color.gray.opacity(0.5 * opacity))
                    .frame(width: 10, height: 120)
                
                Spacer()
            }
            .frame(width: 93)
            
            // Title lines
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.4 * opacity))
                        .frame(width: 60, height: 6)
                }
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.4 * opacity))
                    .frame(width: 40, height: 6)
            }
            .padding(.leading, 20)
            
            // Shimmer effect
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.gray.opacity(0.2 * opacity),
                            Color.white.opacity(0.5 * opacity),
                            Color.gray.opacity(0.2 * opacity)
                        ]),
                        startPoint: UnitPoint(x: shimmerOffset, y: 0.5),
                        endPoint: UnitPoint(x: shimmerOffset + 1, y: 0.5)
                    )
                )
                .frame(width: 93, height: 120)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 1.25
            }
        }
    }
}
