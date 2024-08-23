//
//  RegisterView.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 20/08/24.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct RegisterView: View {
    
    @State var userName: String = ""
    @State var emailId: String = ""
    @State var password: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data?
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var shoulShowLoading: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var userProfileURL: URL?
    @AppStorage("usernameStored") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Lets Register an\nAccount")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Hello user, have a wonderful journey")
                .font(.title3)
                .hAlign(.leading)
            
            ViewThatFits {
                ScrollView(.vertical, showsIndicators: false) {
                    HelperView()
                }
                
                HelperView()
            }
            
            HStack {
                Text("Already have an account ?")
                    .foregroundStyle(.gray)
                
                Button("Login now") {
                    dismiss()
                }
                .fontWeight(.bold)
                .foregroundStyle(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(shouldShowLoading: $shoulShowLoading)
        })
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { _, newValue in
            
            // MARK: Extracting UIImage from photoItem
            
            if let newValue {
                Task {
                    do {
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else {
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
        }
        .alert(errorMessage, isPresented: $showError) {
            
        }
    }
    
    @ViewBuilder
    func HelperView() -> some View {
        VStack(spacing: 12) {
            ZStack {
                if let userProfilePicData,
                   let image = UIImage(data: userProfilePicData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundStyle(.blue)
                }
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .padding(.top, 25)
            .onTapGesture {
                showImagePicker.toggle()
            }
            
            TextField("User name", text: $userName)
                .border(1, .gray.opacity(0.5))
                .padding(.top, 25)
            
            TextField("Email", text: $emailId)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("About You", text: $userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("Bio link (Optional)", text: $userBioLink)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            SecureField("Password", text: $password)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            Button {
                register()
            } label: {
                Text("Sing in")
                    .foregroundStyle(.white)
                    .hAlign(.center)
                    .fillView(color: .black)
            }
            .padding(.top, 10)
            .disableWithOpacity(isFormValid())
        }
    }
    
    func register() {
        closeKeyboard()
        
        shoulShowLoading = true
        
        Task {
            do {
                try await Auth.auth().createUser(withEmail: emailId, password: password)
                
                guard let userUID = Auth.auth().currentUser?.uid,
                      let imageData = userProfilePicData else { return }
                
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                
                let _ = try await storageRef.putDataAsync(imageData)
                
                let downloadURL = try await storageRef.downloadURL()
                
                let user = User(username: userName,
                                userBio: userBio,
                                userBioLink: userBioLink,
                                userUID: userUID,
                                userEmail: emailId,
                                userProfileURL: downloadURL)
                
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user) { error in
                    if error == nil {
                        print("user saved")
                        shoulShowLoading = false
                        
                        usernameStored = userName
                        self.userUID = userUID
                        userProfileURL = downloadURL
                        logStatus = true
                    }
                }
                
            } catch {
                await setError(error)
            }
        }
    }
    
    func setError(_ error: Error) async {
        shoulShowLoading = false
        
        await MainActor.run {
            errorMessage = error.localizedDescription
            
            showError.toggle()
        }
    }
    
    func isFormValid() -> Bool {
        
        userName.isEmpty ||
        emailId.isEmpty ||
        password.isEmpty ||
        userBio.isEmpty ||
        userProfilePicData == nil
    }
}

#Preview {
    RegisterView()
}
