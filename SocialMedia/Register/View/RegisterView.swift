//
//  RegisterView.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 20/08/24.
//

import SwiftUI
import PhotosUI

struct RegisterView: View {
    
    @StateObject private var viewModel = RegisterViewModel()
    
    @Environment(\.dismiss) var dismiss
    
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
                    RegisterFormView()
                }
                
                RegisterFormView()
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
            LoadingView(shouldShowLoading: $viewModel.shouldShowLoading)
        })
        .photosPicker(isPresented: $viewModel.shouldShowImagePicker, selection: $viewModel.photoItem)
        .onChange(of: viewModel.photoItem) { _, newValue in
            
            // MARK: Extracting UIImage from photoItem
            
            if let newValue {
                viewModel.extractImageFromPhotoItem(newValue)
            }
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.shouldShowAlert) {
            if viewModel.alertMessage == "User created successfully!" {
                Button("OK") {
                    viewModel.logStatus = true
                }
            }
        }
    }
    
    @ViewBuilder
    func RegisterFormView() -> some View {
        VStack(spacing: 12) {
            ZStack {
                if let userProfilePicData = viewModel.userProfilePicData,
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
                viewModel.shouldShowImagePicker.toggle()
            }
            
            TextField("User name", text: $viewModel.username)
                .border(1, .gray.opacity(0.5))
                .padding(.top, 25)
            
            TextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("About You", text: $viewModel.userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("Bio link (Optional)", text: $viewModel.userBioLink)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            SecureField("Password", text: $viewModel.password)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            Button {
                closeKeyboard()
                viewModel.register()
            } label: {
                Text("Sing in")
                    .foregroundStyle(.white)
                    .hAlign(.center)
                    .fillView(color: .black)
            }
            .padding(.top, 10)
            .disableWithOpacity(viewModel.isFormValid())
        }
    }
}

#Preview {
    RegisterView()
}
