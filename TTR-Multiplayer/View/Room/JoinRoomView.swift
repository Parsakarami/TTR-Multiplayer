//
//  JoinRoomView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-04.
//

import SwiftUI

struct JoinRoomView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = JoinRoomViewModel()
    var body: some View {
        VStack{
            Text("Join a Room")
                .font(.system(size: 22,weight: .bold, design: .default))
            
            Form {
                if viewModel.message != "" {
                    Text(viewModel.message)
                        .foregroundColor(viewModel.isSuccessful ? .green : .red)
                        .padding()
                }
                
                TextField("Access Code", text: $viewModel.roomAccessCode )
                    .autocorrectionDisabled()
                    .padding()
                    .monospacedDigit()
                    .cornerRadius(6)
                
                HStack{
                    Spacer()
                    if !viewModel.isJoining {
                        TTRButton(action: {
                            Task(priority: .high){
                                do {
                                    try await viewModel.joinRoom()
                                }catch {
                                    print(error)
                                }
                            }
                        }, text: "Join", icon: "link", bgColor: viewModel.isSuccessful ? .gray : .blue)
                        .disabled(viewModel.isSuccessful)
                        .frame(height: 50)
                        .padding([.top,.bottom],10)
                    } else {
                        ProgressView()
                            .padding()
                    }
                    Spacer()
                }
            }
        }
        .onChange(of: viewModel.isSuccessful) { value in
            if value {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if presentationMode.wrappedValue.isPresented {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    JoinRoomView()
}
