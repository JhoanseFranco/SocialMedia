//
//  MainView.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 28/08/24.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PostsView()
                .tabItem {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text(MainTabStrings.posts)
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "gear")
                    Text(MainTabStrings.profile)
                }
        }
        .tint(.black)
    }
}

#Preview {
    MainTabView()
}
