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
    
    func doLogout() async
    func deleteAccount() async
    func fetchUser() async throws -> User?
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
    func didDoLogout() async
    func didFailDoingLogout(message: String) async
    func didDeleteAccount() async
    func didFailDeletingAccount(message: String) async
}

final class FirebaseService: FirebaseServiceProvider {
    
    public var delegate: FirebaseServiceDelegate?
    
    private var userUID: String? {
        Auth.auth().currentUser?.uid
    }
    
    init(delegate: FirebaseServiceDelegate? = nil) {
        self.delegate = delegate
    }
    
    func signIn(email: String, password: String) async {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            
            let user = try await fetchUser()
            
            await MainActor.run {
                guard let userUID,
                      let user else { return }
                
                delegate?.didSignIn(userUID: userUID,
                                    usernameStored: user.username,
                                    profileImageURL: user.profileImageURL)
            }
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
            
            guard let userUID,
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
    
    func doLogout() async {
        do {
            try Auth.auth().signOut()
            await delegate?.didDoLogout()
        } catch {
            await delegate?.didFailDoingLogout(message: error.localizedDescription)
        }
    }
    
    func deleteAccount() async {
        Task {
            do {
                guard let userUID else { return }
                
                try await deleteProfileImageFromStorage(userUID: userUID)
                try await deleteUserDocumentFromFirestore(userUID: userUID)
                try await deleteUser()
                await delegate?.didDeleteAccount()
            } catch {
                await delegate?.didFailDeletingAccount(message: error.localizedDescription)
            }
        }
    }
    
    func fetchUser() async throws -> User? {
        guard let userUID else { return nil }
        
        let user = try await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self)
        
        return user
    }
}



// MARK: - Private methods

private extension FirebaseService {
    
    func deleteProfileImageFromStorage(userUID: String) async throws {
        let reference = Storage.storage().reference().child("Profile_Images").child(userUID)
        
        try await reference.delete()
    }
    
    func deleteUserDocumentFromFirestore(userUID: String) async throws {
        let reference = Firestore.firestore().collection("Users").document(userUID)
        
        try await reference.delete()
    }
    
    func deleteUser() async throws {
        try await Auth.auth().currentUser?.delete()
    }
}
