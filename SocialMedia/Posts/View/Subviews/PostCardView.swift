//
//  PostCardView.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 5/09/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct PostCardView: View {
    
    @ObservedObject var viewModel: PostsViewModel
    
    var post: Post
    var onUpdate: (Post) -> Void
    var onDelete: () -> ()
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            WebImage(url: post.profileImageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(post.username)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                Text(post.publishedDate.formatted(date: .numeric, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.gray)
                
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical, 8)
                
                if let postImageURL = post.imageURL {
                    GeometryReader {
                        let size = $0.size
                        
                        WebImage(url: postImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .frame(height: 200)
                }
                
                PostInteraction()
            }
        }
        .hAlign(.leading)
        .overlay(alignment: .topTrailing, content: {
            if post.userUID == viewModel.userUID {
                Menu {
                    Button("Delete Post", role: .destructive, action: { viewModel.deletePost(post) })
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .rotationEffect(.init(degrees: -90))
                        .foregroundStyle(.black)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x: 8)
            }
        })
        .onAppear {
            guard let postID = post.id else { return }
            
            viewModel.addSnapshotListener(postID: postID,
                                          onUpdate: onUpdate,
                                          onDelete: onDelete)
        }
        .onDisappear {
            if let docListener = viewModel.docListener {
                docListener.remove()
                
                viewModel.docListener = nil
            }
        }
    }
    
    @ViewBuilder
    func PostInteraction() -> some View {
        HStack(spacing: 6) {
            Button {
                viewModel.updateLikedData(post, interactionType: .like)
            } label: {
                Image(systemName: post.likedIds.contains(viewModel.userUID) ? "hand.thumbsup.fill" : "hand.thumbsup")
            }
            
            Text("\(post.likedIds.count)")
                .font(.caption)
                .foregroundStyle(.gray)
            
            Button {
                viewModel.updateLikedData(post, interactionType: .dislike)
            } label: {
                Image(systemName: post.dislikedIds.contains(viewModel.userUID) ? "hand.thumbsdown.fill" : "hand.thumbsdown")
            }
            .padding(.leading, 24)
            
            Text("\(post.dislikedIds.count)")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .foregroundStyle(.black)
        .padding(.vertical, 8)
    }
}
