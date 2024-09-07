//
//  Post.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 1/09/24.
//

import Foundation
import FirebaseFirestore

struct Post: Codable, Identifiable {
    
    @DocumentID var id: String?
    let text: String
    let imageURL: URL?
    var imageReferenceId: String
    var publishedDate: Date
    var likedIds: [String]
    var dislikedIds: [String]
    let username: String
    let userUID: String
    let profileImageURL: URL
    
    init(id: String? = nil,
         text: String,
         imageURL: URL? = nil,
         imageReferenceId: String = "",
         publishedDate: Date = Date(),
         likedIds: [String] = [],
         dislikedIds: [String] = [],
         username: String,
         userUID: String,
         profileImageURL: URL) {
        self.id = id
        self.text = text
        self.imageURL = imageURL
        self.imageReferenceId = imageReferenceId
        self.publishedDate = publishedDate
        self.likedIds = likedIds
        self.dislikedIds = dislikedIds
        self.username = username
        self.userUID = userUID
        self.profileImageURL = profileImageURL
    }
}
