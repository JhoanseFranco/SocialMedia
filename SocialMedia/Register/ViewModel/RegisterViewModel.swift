//
//  RegisterViewModel.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 27/08/24.
//

import SwiftUI
import PhotosUI

@MainActor
final class RegisterViewModel: ObservableObject {
    
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var userBio: String = ""
    @Published var userBioLink: String = ""
    @Published var userProfilePicData: Data?
    @Published var shouldShowImagePicker: Bool = false
    @Published var photoItem: PhotosPickerItem?
    @Published var shouldShowLoading: Bool = false
    @Published var alertMessage: LocalizedStringKey = ""
    @Published var shouldShowAlert: Bool = false
    
    @AppStorage("usernameStored") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("user_profile_url") var userProfileURL: URL?
    @AppStorage("should_be_logged") var shouldBeLogged: Bool = false
    
    lazy var firebaseService = FirebaseService(delegate: self)
    
    func register() {
        shouldShowLoading = true
        
        Task {
            await firebaseService.createUser(username: username,
                                             userBio: userBio,
                                             userBioLink: userBioLink,
                                             email: email,
                                             password: password,
                                             userProfilePicData: userProfilePicData)
        }
    }
    
    func extractImageFromPhotoItem(_ photoItem: PhotosPickerItem) {
        Task {
            do {
                guard let imageData = try await photoItem.loadTransferable(type: Data.self) else {
                    print ("Fail extracting Image from photoItem")
                    
                    return
                }
                
                await MainActor.run {
                    userProfilePicData = imageData
                }
            } catch {
                print ("Fail extracting Image from photoItem")
            }
        }
    }
    
    func isFormValid() -> Bool {
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        userBio.isEmpty ||
        userProfilePicData == nil
    }
}


// MARK: FirebaseServiceDelegate conformance

extension RegisterViewModel: FirebaseServiceDelegate {
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
    
    func didCreateUser(userUID: String,
                       userProfileURL: URL) {
        shouldShowLoading = false
        alertMessage = RegisterStrings.userCreateSuccessfullyMessage
        usernameStored = username
        self.userUID = userUID
        self.userProfileURL = userProfileURL
        
        shouldShowAlert.toggle()
    }
    
    func didFailCreatingUser(message: String) async {
        shouldShowLoading = false
        alertMessage = LocalizedStringKey(message)
        
        shouldShowAlert.toggle()
    }
}
