//
//  LoginViewModel.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 23/08/24.
//

import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    
    @Published var shouldShowLoading: Bool = false
    @Published var shouldShowError: Bool = false
    @Published var shouldShowRegisterView: Bool = false
    @Published var alertMessage: LocalizedStringKey = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("usernameStored") var usernameStored: String = ""
    @AppStorage("user_profile_url") var profileImageURL: URL?
    
    private lazy var firebaseService: FirebaseServiceProvider = FirebaseService(delegate: self)
    
    lazy var loginView = LoginView()
    
    func login() {
        shouldShowLoading = true
        
        Task {
            await firebaseService.signIn(email: email, password: password)
        }
    }
    
    func resetPassword() {
        shouldShowLoading = true
        
        Task {
            await firebaseService.resetPassword(email: email)
        }
    }
}


// MARK: - FirebaseServiceDelegate conformance

extension LoginViewModel: FirebaseServiceDelegate {
    
    func didSignIn(userUID: String, usernameStored: String, profileImageURL: URL) {
        self.userUID = userUID
        self.usernameStored = usernameStored
        self.profileImageURL = profileImageURL
        shouldShowLoading = false
        logStatus = true
    }
    
    func didFailSignIn(message: String) async {
        shouldShowLoading = false
        alertMessage = LocalizedStringKey(message)
        
        shouldShowError.toggle()
    }
    
    func didResetPassword() async {
        shouldShowLoading = false
        alertMessage = LoginStrings.resetPasswordSuccessMessage
        
        shouldShowError.toggle()
    }
    
    func didFailResetingPassword(message: String) async {
        shouldShowLoading = false
        alertMessage = LocalizedStringKey(message)
        
        shouldShowError.toggle()
    }
    
    func didCreateUser(userUID: String, userProfileURL: URL) {
        // No-op
    }
    
    func didFailCreatingUser(message: String) {
        // No-op
    }
}
