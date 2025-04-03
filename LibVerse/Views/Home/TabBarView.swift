//
//  TabBarView.swift
//  LibVerse
//
//  Created by Piyush on 31/03/25.
//

import Foundation
import SwiftUI

struct TabBarView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(LocalizationManager.shared.localizedString("home"))
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text(LocalizationManager.shared.localizedString("search"))
                }
                .tag(1)
            
            myshelf()
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text(LocalizationManager.shared.localizedString("my_shelf"))
                }
                .tag(2)
            
            MyBag()
                .tabItem {
                    Image(systemName: "bag.fill")
                    Text(LocalizationManager.shared.localizedString("my_bag"))
                }
                .tag(3)
            
//            UserProfileView(showMainApp: .constant(true), showUserInitialView: .constant(true))
//                .tabItem {
//                    Image(systemName: "person.crop.circle")
//                    Text("Profile")
//                }
//                .tag(4)
        }
        .tint(Color(red:255/255, green: 111/255, blue: 45/255))
        .onAppear {
            // Set the tab bar background color
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 255/255, green: 239/255, blue: 210/255, alpha: 1.0)
            
            // Use this appearance for both normal and scrolling states
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .id(localizationManager.currentLanguage.rawValue) // Force view refresh when language changes
    }
}
