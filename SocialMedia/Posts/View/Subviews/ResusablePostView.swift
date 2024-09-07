//
//  ResusablePostView.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 5/09/24.
//

import SwiftUI

struct ResusablePostView: View {
    
    @ObservedObject private var viewModel: PostsViewModel
    
    init(viewModel: PostsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                if viewModel.isFetchingPosts {
                    ProgressView()
                        .padding(.top, 30)
                } else {
                    if viewModel.recentPosts.isEmpty {
                        Text(PostsStrings.ReusablePost.postsNotFound)
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .padding(.top, 30)
                    } else {
                        Posts()
                    }
                }
            }
            .padding(16)
        }
        .refreshable {
            viewModel.recentPosts.removeAll()
            
            await viewModel.fetchPosts()
        }
        .task {
            guard viewModel.recentPosts.isEmpty else { return }
            
            await viewModel.fetchPosts()
        }
    }
    
    @ViewBuilder
    func Posts() -> some View {
        ForEach(viewModel.recentPosts) { post in
            PostCardView(viewModel: viewModel,
                         post: post) { updatedPost in
                if let index = viewModel.recentPosts.firstIndex(where: { $0.id == updatedPost.id }) {
                    viewModel.recentPosts[index].likedIds = updatedPost.likedIds
                    viewModel.recentPosts[index].dislikedIds = updatedPost.dislikedIds
                }
            } onDelete: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.recentPosts.removeAll { $0.id == post.id }
                }
            }

            Divider()
                .padding(.horizontal, -16)
        }
    }
}

#Preview {
    ContentView()
}
