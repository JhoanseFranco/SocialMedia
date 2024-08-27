//
//  FirebaseService.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 23/08/24.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

protocol FirebaseServiceProvider: AnyObject {
    
    func signIn(email: String, password: String) async
    func resetPassword(email: String) async
    
    func createUser(username: String,
                    userBio: String,
                    userBioLink: String,
                    email: String,
                    password: String,
                    userProfilePicData: Data?) async
}

protocol FirebaseServiceDelegate {
    
    func didSignIn(userUID: String,
                   usernameStored: String,
                   profileImageURL: URL)
    
    func didFailSignIn(message: String) async
    func didResetPassword() async
    func didFailResetingPassword(message: String) async
    
    func didCreateUser(userUID: String,
                       userProfileURL: URL)
    
    func didFailCreatingUser(message: String) async
}

final class FirebaseService: FirebaseServiceProvider {
    
    public var delegate: FirebaseServiceDelegate?
    
    init(delegate: FirebaseServiceDelegate? = nil) {
        self.delegate = delegate
    }
    
    func signIn(email: String, password: String) async {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            try await fetchUser()
        } catch {
            await delegate?.didFailSignIn(message: error.localizedDescription)
        }
    }
    
    func resetPassword(email: String) async {
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                await delegate?.didResetPassword()
            } catch {
                await delegate?.didFailResetingPassword(message: error.localizedDescription)
            }
        }
    }
    
    func createUser(username: String,
                    userBio: String,
                    userBioLink: String,
                    email: String,
                    password: String,
                    userProfilePicData: Data?) async {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
            
            guard let userUID = Auth.auth().currentUser?.uid,
                  let imageData = userProfilePicData else { return }
            
            let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
            
            let _ = try await storageRef.putDataAsync(imageData)
            
            let userProfileURL = try await storageRef.downloadURL()
            
            let user = User(username: username,
                            userBio: userBio,
                            userBioLink: userBioLink,
                            userUID: userUID,
                            userEmail: email,
                            profileImageURL: userProfileURL)
            
            let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user) { [weak self] error in
                if error == nil {
                    self?.delegate?.didCreateUser(userUID: userUID,
                                                  userProfileURL: userProfileURL)
                }
            }
            
        } catch {
            await delegate?.didFailCreatingUser(message: error.localizedDescription)
        }
    }
}



// MARK: - Private methods

private extension FirebaseService {
    
    func fetchUser() async throws {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let user = try await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self)
        
        await MainActor.run {
            delegate?.didSignIn(userUID: userUID,
                                usernameStored: user.username,
                                profileImageURL: user.profileImageURL)
        }
    }
}
