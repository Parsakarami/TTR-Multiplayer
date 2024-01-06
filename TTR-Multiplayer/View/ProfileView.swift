//
//  Profile.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-05.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    var body: some View {
        VStack {
            Text("Profile")
                .font(.system(size: 22,weight: .bold, design: .default))
            
            Form {
                if viewModel.message != "" && viewModel.isUpdating == false {
                        Text(viewModel.message)
                            .foregroundColor(viewModel.isSuccessful ? .green : .red)
                            .padding()
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.updateProfile()
                    }){
                        PhotoPickerPreview(selectedImage: $viewModel.selectedImage)
                    }
                    Spacer()
                }
                
                HStack (spacing: 10){
                    Text("Full name")
                        .font(.system(size: 15,weight:.medium,design: .default))
                        .foregroundColor(.gray)
                        .frame(maxWidth: 80,alignment: .leading)
                    
                    Text(viewModel.player?.fullName ?? "")
                        .font(.system(size: 16,weight: .semibold,design: .default))
                        .frame(maxWidth: 190,alignment: .leading)
                }.padding()
                
                HStack (spacing: 10){
                    Text("Email")
                        .font(.system(size: 15,weight:.medium,design: .default))
                        .foregroundColor(.gray)
                        .frame(maxWidth: 80,alignment: .leading)
                    Text(viewModel.player?.email ?? "")
                        .font(.system(size: 16,weight: .semibold,design: .default))
                        .frame(maxWidth: 190,alignment: .leading)
                }.padding()
                
                HStack (alignment: .center) {
                    Spacer()
                    if viewModel.isUpdating {
                        ProgressView()
                            .frame(height: 50)
                            .padding()
                    } else {
                        TTRButton(action: {
                            viewModel.updateProfile()
                        }, text: "Update profile", icon: "pencil", bgColor: .green)
                        .disabled(viewModel.isUpdating)
                        .frame(height: 50)
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
}
