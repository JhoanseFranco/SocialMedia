//
//  CreatePostView.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 1/09/24.
//

import SwiftUI

struct CreatePostView: View {
    
    let onPost: ((Post) -> Void)
    
    @StateObject private var viewModel = CreatePostViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    @FocusState var shouldShowKeyboard: Bool
    
    var body: some View {
        VStack {
            HStack {
                Menu {
                    Button(CommonStrings.cancel, role: .destructive) {
                        dismiss()
                    }
                } label: {
                    Text(CommonStrings.cancel)
                        .font(.callout)
                        .foregroundStyle(.black)
                }
                .hAlign(.leading)
                
                Button(action: viewModel.createPost) {
                    Text(CreatePostStrings.posts)
                        .font(.callout)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .background(.black, in: Capsule())
                }
                .disableWithOpacity(viewModel.postText.isEmpty)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .ignoresSafeArea()
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    TextField(CreatePostStrings.whatsHappening, text: $viewModel.postText)
                        .focused($shouldShowKeyboard)
                    
                    if let imageData = viewModel.postImageData,
                       let image = UIImage(data: imageData) {
                        GeometryReader {
                            let size = $0.size
                            
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            self.viewModel.postImageData = nil
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .fontWeight(.bold)
                                            .tint(.red)
                                    }
                                }
                        }
                        .clipped()
                        .frame(height: 220)
                    }
                }
                .padding(15)
            }
            
            Divider()
            
            HStack {
                Button {
                    viewModel.shouldShowImagePicker.toggle()
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title3)
                }
                .hAlign(.leading)
                
                Button(CommonStrings.done) {
                    viewModel.shouldShowKeyboard = false
                }
            }
            .foregroundColor(.black)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
        }
        .vAlign(.top)
        .photosPicker(isPresented: $viewModel.shouldShowImagePicker, selection: $viewModel.photoItem)
        .onChange(of: viewModel.photoItem) { _, newValue in
            if let newValue {
                Task {
                    if let rawImageData = try? await newValue.loadTransferable(type: Data.self),
                       let image = UIImage(data: rawImageData),
                       let compressedImageData = image.jpegData(compressionQuality: 0.5) {
                        await MainActor.run {
                            viewModel.postImageData = compressedImageData
                            viewModel.photoItem = nil
                        }
                    }
                }
            }
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.shouldShowAlerMessage) {}
        .overlay {
            LoadingView(shouldShowLoading: $viewModel.shouldShowLoading)
        }
        .onChange(of: viewModel.shouldDismiss) { _, newValue in
            if newValue {
                if let post = viewModel.post {
                    onPost(post)
                }
                
                dismiss()
            }
        }
        .onReceive(viewModel.$shouldShowKeyboard) { shouldShowKeyboard in
            self.shouldShowKeyboard = shouldShowKeyboard
        }
    }
}

#Preview {
    CreatePostView(onPost: { _ in })
}
