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
                HStack {
                    Spacer()
                Button(action: {
                    viewModel.uploadProfile()
                }){
                    VStack {
                        AsyncImage(url: URL(string: viewModel.profilePhoto)) { image in
                            image.resizable()
                                .scaledToFit()
                                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                .clipShape(.circle)
                                .padding(10)
                                
                        } placeholder: {
                            ProgressView()
                        }
                        .padding(5)
                        .frame(width: 125, height: 125)
                    }
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
                
                
                TTRButton(action: {
                    viewModel.updateProfile()
                }, text: "Update profile", icon: "pencil", bgColor: .green)
                .frame(height: 50)
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
}
