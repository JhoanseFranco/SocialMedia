//
//  FirebaseService.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 23/08/24.
//

import FirebaseAuth
import FirebaseFirestore

protocol FirebaseServiceProvider: AnyObject {
    
    func signIn(email: String, password: String) async
    func resetPassword(email: String) async
}

protocol FirebaseServiceDelegate {
    
    func didSignIn(userUID: String,
                   usernameStored: String,
                   profileImageURL: URL)
    
    func didFailSignIn(message: String) async
    func didResetPassword() async
    func didFailResetingPassword(message: String) async
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
