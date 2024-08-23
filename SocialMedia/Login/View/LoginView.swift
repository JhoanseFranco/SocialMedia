//
//  LoginView.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 20/08/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    
    @State var emailId: String = ""
    @State var password: String = ""
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var shoulShowLoading: Bool = false
    
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var userProfileURL: URL?
    @AppStorage("usernameStored") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Lets Sing you in")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Welcome back, \nYou have been missed")
                .font(.title3)
                .hAlign(.leading)
            
            VStack(spacing: 12) {
                TextField("Email", text: $emailId)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top, 25)
                
                SecureField("Password", text: $password)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                
                Button("Reset Password", action: resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button {
                    login()
                } label: {
                    Text("Sing in")
                        .foregroundStyle(.white)
                        .hAlign(.center)
                        .fillView(color: .black)
                }
                .padding(.top, 10)
            }
            
            HStack {
                Text("Don't have an account ?")
                    .foregroundStyle(.gray)
                
                Button("Register now") {
                    createAccount.toggle()
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
        .fullScreenCover(isPresented: $createAccount) {
            RegisterView()
        }
        .alert(errorMessage, isPresented: $showError) {
            
        }
    }
    
    func login() {
        closeKeyboard()
        
        shoulShowLoading = true
        
        Task {
            do {
                try await Auth.auth().signIn(withEmail: emailId, password: password)
                try await fetchUser()
            } catch {
                await setError(error)
            }
        }
    }
    
    func fetchUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        
        await MainActor.run {
            shoulShowLoading = false
            userUID = userID
            usernameStored = user.username
            userProfileURL = user.userProfileURL
            logStatus = true
        }
    }
    
    func resetPassword() {
        shoulShowLoading = true
        
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: emailId)
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
}

extension View {
    
    func hAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
    func border(_ width: CGFloat, _ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
    }
    
    func fillView(color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color)
            }
    }
    
    func disableWithOpacity(_ isDisabled: Bool) -> some View {
        self
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.6 : 1)
    }
    
    func closeKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
    }
}
