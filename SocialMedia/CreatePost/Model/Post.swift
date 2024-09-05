//
//  Post.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 1/09/24.
//

import Foundation
import FirebaseFirestore

struct Post: Codable {
    
    @DocumentID var id: String?
    let text: String
    let imageURL: URL?
    let imageReferenceId: String
    let PublishedDate: Date
    let linkedIds: [String]
    let dislikedIds: [String]
    let username: String
    let userUID: String
    let profileImageURL: URL
}
