//
//  User.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 20/08/24.
//

import FirebaseFirestore


struct User: Codable {
    
    @DocumentID var id: String?
    
    var username: String
    var userBio: String
    var userBioLink: String
    var userUID: String
    var userEmail: String
    var profileImageURL: URL
}
