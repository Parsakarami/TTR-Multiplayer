//
//  NewRoomView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-03.
//

import SwiftUI

struct NewRoomView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = NewRoomViewModel()
    var body: some View {
        VStack{
            Text("New Room")
                .font(.system(size: 22,weight: .bold, design: .default))
            
            Form {
                if viewModel.errorMessage != "" {
                    Text(viewModel.errorMessage)
                        .foregroundColor(viewModel.isSuccessful ? .green : .red)
                        .padding()
                }
                
                TextField("Access Code", text: $viewModel.roomCode )
                    .padding()
                    .monospacedDigit()
                    .cornerRadius(6)
                
                VStack{
                    HStack (alignment: .center){
                            Text("^[\(Int(viewModel.roomCapacity)) Player](inflect: true)")
                    }
                        .foregroundColor(.gray)
                    Slider(value: $viewModel.roomCapacity,
                           in: 1...5, step: 1, minimumValueLabel: Text("1"), maximumValueLabel: Text("5")) {
                        Text("Parsa")
                    }
                }
                .padding(5)
                
                TTRButton(action: {
                    if (!viewModel.isSuccessful) {
                        viewModel.addNewRoom()
                    }
                }, text: "Add", icon: "plus", bgColor: viewModel.isSuccessful ? .gray : .green)
                    .disabled(viewModel.isSuccessful)
                    .frame(height: 50)
                    .padding()
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
    NewRoomView()
}
