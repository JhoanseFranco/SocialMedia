//
//  ContentView.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 20/08/24.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("should_be_logged") var shouldBeLogged: Bool = false
    
    var body: some View {
        if shouldBeLogged {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
