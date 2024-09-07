//
//  ProfileViewModel.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 28/08/24.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var shouldShowLoading: Bool = false
    @Published var shouldShowError: Bool = false
    @Published var alertMessage: LocalizedStringKey = ""
    
    @AppStorage("should_be_logged") var shouldBeLogged: Bool = false
    
    lazy var firebaseService = FirebaseService(delegate: self)
    
    func doLogout() {
        shouldShowLoading = true
        
        Task {
            await firebaseService.doLogout()
        }
    }
    
    func deleteAccount() {
        shouldShowLoading = true
        
        Task {
            await firebaseService.deleteAccount()
        }
    }
    
    func fetchUser() {
        Task {
            do {
                user = try await firebaseService.fetchUser()
            } catch {
                alertMessage = LocalizedStringKey(error.localizedDescription)
                
                shouldShowError.toggle()
            }
        }
    }
}


// MARK: FirebaseServiceDelegate conformance

extension ProfileViewModel: FirebaseServiceDelegate {
    
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
        shouldShowLoading = false
        shouldBeLogged = false
    }
    
    func didFailDoingLogout(message: String) async {
        shouldShowLoading = false
        alertMessage = LocalizedStringKey(message)
        
        shouldShowError.toggle()
    }
    
    func didDeleteAccount() async {
        shouldShowLoading = false
        shouldBeLogged = false
    }
    
    func didFailDeletingAccount(message: String) async {
        shouldShowLoading = false
        alertMessage = LocalizedStringKey(message)
        
        shouldShowError.toggle()
    }
    
    func didCreatePost(_ post: Post) {
        // No-op
    }
    
    func didFailCreatingPost(message: String) async {
        // No-op
    }
    
    func didFetchPosts(_ fetchedPosts: [Post]) {
        // No-op
    }
    
    func didFailFetchingPosts(message: String) async {
        // No-op
    }
}
