//
//  CreatePostViewModel.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 1/09/24.
//

import SwiftUI
import PhotosUI

@MainActor
final class CreatePostViewModel: ObservableObject {
    
    private lazy var firebaseService: FirebaseServiceProvider = FirebaseService(delegate: self)
    
    var post: Post?
    
    @Published var postText: String = ""
    @Published var postImageData: Data?
    @Published var shouldShowLoading: Bool = false
    @Published var shouldShowAlerMessage: Bool = false
    @Published var alertMessage: LocalizedStringKey = ""
    @Published var shouldShowImagePicker: Bool = false
    @Published var photoItem: PhotosPickerItem?
    @Published var shouldDismiss: Bool = false
    @Published var shouldShowKeyboard: Bool = false
    
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("usernameStored") var usernameStored: String = ""
    @AppStorage("user_profile_url") var profileImageURL: URL?
    
    func createPost() {
        shouldShowKeyboard = false
        
        Task {
            guard let profileImageURL else { return }
            
            shouldShowLoading = true
            
            let imageReferenceID = "\(userUID)\(Date())"
            
            await firebaseService.createPost(username: usernameStored,
                                             postText: postText,
                                             profileImageURL: profileImageURL,
                                             imageReferenceID: imageReferenceID,
                                             postImageData: postImageData)
        }
    }
}


// MARK: FirebaseServiceDelegate methods

extension CreatePostViewModel: FirebaseServiceDelegate {
    
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
        self.post = post
        shouldShowLoading = false
        shouldDismiss = true
    }
    
    func didFailCreatingPost(message: String) async {
        shouldShowLoading = false
        alertMessage = LocalizedStringKey(message)
        
        shouldShowAlerMessage.toggle()
    }
    
    func didFetchPosts(_ fetchedPosts: [Post]) {
        // No-op
    }
    
    func didFailFetchingPosts(message: String) async {
        // No-op
    }
}
