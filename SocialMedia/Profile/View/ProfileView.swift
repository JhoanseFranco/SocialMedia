//
//  ProfileView.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 28/08/24.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if let user = viewModel.user {
                    ReusableProfileView(user: user)
                        .refreshable {
                            viewModel.fetchUser()
                        }
                } else {
                    ProgressView()
                }
            }
            .task {
                if viewModel.user == nil {
                    viewModel.fetchUser()
                }
            }
            .navigationTitle(ProfileStrings.myProfile)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(ProfileStrings.logout, action: viewModel.doLogout)
                        Button(ProfileStrings.deleteAccount, role: .destructive, action: viewModel.deleteAccount)
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .overlay(content: {
            LoadingView(shouldShowLoading: $viewModel.shouldShowLoading)
        })
        .alert(viewModel.alertMessage, isPresented: $viewModel.shouldShowError) {}
    }
}

#Preview {
    ProfileView()
}
