//
//  ContentView.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 20/08/24.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("log_status") var logStatus: Bool = false
    var body: some View {
        if logStatus {
            Text("Main view")
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
