//
//  PostsView.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 5/09/24.
//

import SwiftUI

struct PostsView: View {
    
    @State var shouldShowCreatePostView: Bool = false
    
    var body: some View {
        Text("Hello, World!")
            .hAlign(.center)
            .vAlign(.center)
            .overlay(alignment: .bottomTrailing) {
                Button {
                    shouldShowCreatePostView.toggle()
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
            .fullScreenCover(isPresented: $shouldShowCreatePostView) {
                CreatePostView()
            }
    }
}

#Preview {
    PostsView()
}
