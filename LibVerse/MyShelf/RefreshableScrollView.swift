//
//  RefreshableScrollView.swift
//  LibVerse
//
//  Created by Piyush on 31/03/25.
//

import Foundation
import SwiftUI

// Define it outside of RefreshableScrollView
struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}



// Keep the RefreshableScrollView since it's still used in myshelf.swift
struct RefreshableScrollView<Content: View>: View {
    var action: () async -> Void
    var content: Content
    
    @State private var isRefreshing = false
    
    init(action: @escaping () async -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                MovingView(action: action, isRefreshing: $isRefreshing)
                
                VStack {
                    content
                }
            }
        }
    }
    
    struct MovingView: View {
        var action: () async -> Void
        @Binding var isRefreshing: Bool
        @State private var offset: CGFloat = 0
        
        var body: some View {
            GeometryReader { geo in
                if geo.frame(in: .global).minY > 0 {
                    Color.clear
                        .preference(key: ScrollViewOffsetPreferenceKey.self, value: geo.frame(in: .global).minY)
                        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                            if value > 120 && !isRefreshing {
                                isRefreshing = true
                                
                                Task {
                                    await action()
                                    withAnimation {
                                        isRefreshing = false
                                    }
                                }
                            }
                        }
                }
            }
            .frame(height: 0)
        }
    }
}
