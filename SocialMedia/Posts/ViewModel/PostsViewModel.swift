//
//  PostsViewModel.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 5/09/24.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class PostsViewModel: ObservableObject {
    
    private lazy var firebaseService: FirebaseServiceProvider = FirebaseService(delegate: self)
    
    @Published var recentPosts: [Post] = []
    @Published var shouldShowCreatePostView: Bool = false
    @Published var isFetchingPosts: Bool = true
    
    @State var docListener: ListenerRegistration?
    
    @AppStorage("user_UID") var userUID: String = ""
    
    func fetchPosts() async {
        isFetchingPosts = true
        
        await firebaseService.fetchPosts()
    }
    
    func updateLikedData(_ post: Post, interactionType: Interaction) {
        Task {
               firebaseService.updateLikedData(post: post,
                                               userUID: userUID,
                                               interactionType: interactionType)
        }
    }
    
    func addSnapshotListener(postID: String,
                             onUpdate: @escaping (Post) -> Void,
                             onDelete: @escaping () -> ()) {
        if docListener == nil {
            docListener = firebaseService.addSnapshotListener(postID: postID,
                                                              onUpdate: onUpdate,
                                                              onDelete: onDelete)
        }
    }
    
    func deletePost(_ post: Post) {
        Task {
            await firebaseService.deletePost(post)
        }
    }
}


// MARK: FirebaseServiceDelegate methods

extension PostsViewModel: FirebaseServiceDelegate {
    
    func didSignIn(userUID: String, usernameStored: String, profileImageURL: URL) {
        // No-op
    }
    
    func didFailSignIn(message: String) async {
        // No-op
    }
    
    func didResetPassword() async {
        // No-op
    }
    
    func didFailResetingPassword(message: String) async {
        // No-op
    }
    
    func didCreateUser(userUID: String, userProfileURL: URL) {
        // No-op
    }
    
    func didFailCreatingUser(message: String) async {
        // No-op
    }
    
    func didDoLogout() async {
        // No-op
    }
    
    func didFailDoingLogout(message: String) async {
        // No-op
    }
    
    func didDeleteAccount() async {
        // No-op
    }
    
    func didFailDeletingAccount(message: String) async {
        // No-op
    }
    
    func didCreatePost(_ post: Post) {
        // No-op
    }
    
    func didFailCreatingPost(message: String) async {
        // No-op
    }
    
    func didFetchPosts(_ fetchedPosts: [Post]) {
        recentPosts = fetchedPosts
        isFetchingPosts = false
    }
    
    func didFailFetchingPosts(message: String) async {
        
    }
}
