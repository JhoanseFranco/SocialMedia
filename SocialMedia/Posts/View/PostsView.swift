//
//  PostsView.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 5/09/24.
//

import SwiftUI

struct PostsView: View {
    
    @StateObject private var viewModel = PostsViewModel()
    
    var body: some View {
        NavigationStack {
            ResusablePostView(viewModel: viewModel)
                .hAlign(.center)
                .vAlign(.center)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        viewModel.shouldShowCreatePostView.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(.black, in: Circle())
                    }
                    .padding(16)
                }
                .navigationTitle(PostsStrings.Posts.posts)
        }
        .fullScreenCover(isPresented: $viewModel.shouldShowCreatePostView) {
            CreatePostView { [weak viewModel] post in
                viewModel?.recentPosts.insert(post, at: 0)
            }
        }
    }
}

#Preview {
    PostsView()
}
