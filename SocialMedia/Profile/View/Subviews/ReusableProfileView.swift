//
//  ReusableProfileView.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 28/08/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReusableProfileView: View {
    
    var user: User
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                HStack {
                    WebImage(url: user.profileImageURL, content: { image in
                        image
                            .resizable()
                    }, placeholder: {
                        Image(systemName: "NullProfile")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.username)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(user.userBio)
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .lineLimit(3)
                        
                        if let bioLink = URL(string: user.userBioLink) {
                            Link(destination: bioLink) {
                                Text(user.userBioLink)
                                    .font(.callout)
                                    .tint(.blue)
                                    .lineLimit(1)
                            }
                        }
                    }.hAlign(.leading)
                }
                
                Text("Post's")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .hAlign(.leading)
                    .padding(.vertical, 15)
            }
            .padding(15)
        }
    }
}
