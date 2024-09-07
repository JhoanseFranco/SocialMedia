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
    
    func createPost(username: String,
                    postText: String,
                    profileImageURL: URL,
                    imageReferenceID: String,
                    postImageData: Data?) async
    
    func fetchPosts() async
    
    func updateLikedData(post: Post, 
                         userUID: String,
                         interactionType: Interaction)
    
    func addSnapshotListener(postID: String,
                             onUpdate: @escaping (Post) -> Void,
                             onDelete: @escaping () -> ()) -> ListenerRegistration
    
    func deletePost(_ post: Post) async
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
    func didCreatePost(_ post: Post)
    func didFailCreatingPost(message: String) async
    func didFetchPosts(_ fetchedPosts: [Post])
    func didFailFetchingPosts(message: String) async
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
    
    func createPost(username: String,
                    postText: String,
                    profileImageURL: URL,
                    imageReferenceID: String,
                    postImageData: Data?) async {
        do {
            guard let userUID else { return }
            
            let storageRef = Storage.storage().reference().child("Post_Images").child(imageReferenceID)
            
            if let postImageData {
                let _ = try await storageRef.putDataAsync(postImageData)
                let downloadURL = try await storageRef.downloadURL()
                
                let post = Post(text: postText,
                                imageURL: downloadURL,
                                imageReferenceId: imageReferenceID,
                                username: username,
                                userUID: userUID,
                                profileImageURL: profileImageURL)
                
                try await createDocumentAtFirebase(post)
            } else {
                let post = Post(text: postText,
                                username: username,
                                userUID: userUID,
                                profileImageURL: profileImageURL)
                
                try await createDocumentAtFirebase(post)
            }
        } catch {
            await delegate?.didFailCreatingPost(message: error.localizedDescription)
        }
    }
    
    func fetchPosts() async {
        do {
            let query: Query = Firestore.firestore().collection("Posts")
                .order(by:"publishedDate", descending: true)
                .limit(to: 20)
            
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            
            await MainActor.run {
                delegate?.didFetchPosts(fetchedPosts)
            }
        } catch {
            await delegate?.didFailFetchingPosts(message: error.localizedDescription)
        }
    }
    
    func updateLikedData(post: Post,
                         userUID: String,
                         interactionType: Interaction) {
        guard let id = post.id else { return }
        
        if interactionType == .like {
            if post.likedIds.contains(userUID) {
                Firestore.firestore().collection("Posts").document(id).updateData(["likedIds": FieldValue.arrayRemove([userUID])])
            } else {
                Firestore.firestore().collection("Posts").document(id).updateData(["likedIds": FieldValue.arrayUnion([userUID]),
                                                                                   "dislikedIds": FieldValue.arrayRemove([userUID])])
            }
        } else {
            if post.dislikedIds.contains(userUID) {
                Firestore.firestore().collection("Posts").document(id).updateData(["dislikedIds": FieldValue.arrayRemove([userUID])])
            } else {
                Firestore.firestore().collection("Posts").document(id).updateData(["dislikedIds": FieldValue.arrayUnion([userUID]),
                                                                                   "likedIds": FieldValue.arrayRemove([userUID])])
            }
        }
    }
    
    func addSnapshotListener(postID: String,
                             onUpdate: @escaping (Post) -> Void,
                             onDelete: @escaping () -> ()) -> ListenerRegistration {
        Firestore.firestore().collection("Posts").document(postID).addSnapshotListener({ snapshot, error in
            if let snapshot {
                if snapshot.exists {
                    if let updatedPost = try? snapshot.data(as: Post.self) {
                        onUpdate(updatedPost)
                    }
                } else {
                    onDelete()
                }
            }
        })
    }
    
    func deletePost(_ post: Post) async {
        do {
            if !post.imageReferenceId.isEmpty {
                try await Storage.storage().reference().child("Post_Images").child(post.imageReferenceId).delete()
            }
            
            if let postId = post.id {
                try await Firestore.firestore().collection("Posts").document(postId).delete()
            }
        } catch {
            print("\(CommonStrings.error) \(error.localizedDescription)")
        }
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
    
    func createDocumentAtFirebase(_ post: Post) async throws {
        let doc = Firestore.firestore().collection("Posts").document()
        
        let _ = try doc.setData(from: post) { [weak self] error in
            if error == nil {
                var updatedPost = post
                
                updatedPost.id = doc.documentID
                
                self?.delegate?.didCreatePost(updatedPost)
            }
        }
    }
}
