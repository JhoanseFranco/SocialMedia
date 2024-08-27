//
//  LoginView.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 20/08/24.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 10) {
            Text(LoginStrings.letsSignYou)
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text(LoginStrings.welcome)
                .font(.title3)
                .hAlign(.leading)
            
            VStack(spacing: 12) {
                TextField(LoginStrings.email, text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top, 25)
                
                SecureField(LoginStrings.password, text: $viewModel.password)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                
                Button(LoginStrings.resetPassword, action: viewModel.resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button {
                    closeKeyboard()
                    viewModel.login()
                } label: {
                    Text(LoginStrings.signIn)
                        .foregroundStyle(.white)
                        .hAlign(.center)
                        .fillView(color: .black)
                }
                .padding(.top, 10)
            }
            
            HStack {
                Text(LoginStrings.doNotHaveAnAccount)
                    .foregroundStyle(.gray)
                
                Button("Register now") {
                    viewModel.shouldShowRegisterView.toggle()
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
        .fullScreenCover(isPresented: $viewModel.shouldShowRegisterView) {
            RegisterView()
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.shouldShowError) {}
    }
}

#Preview {
    LoginView()
}
