//
//  LoadingView.swift
//  SocialMedia
//
//  Created by jhoan sebastian franco cardona on 21/08/24.
//

import SwiftUI

struct LoadingView: View {
    
    @Binding var shouldShowLoading: Bool
    
    var body: some View {
        ZStack {
            if shouldShowLoading {
                Group {
                    Rectangle()
                        .fill(.black.opacity(0.25))
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .padding(15)
                        .background(.white, in: RoundedRectangle(cornerRadius: 10,
                                                                 style: .continuous))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: shouldShowLoading)
    }
}
