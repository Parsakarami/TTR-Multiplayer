//
//  NewRoomView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-03.
//

import SwiftUI

struct NewRoomView: View {
    @StateObject var viewModel = NewRoomViewModel()
    var body: some View {
        VStack{
            AnimatedHeader()
            Text("Create a room")
                .font(.title)
            
            Form {
                
                if viewModel.errorMessage != "" {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                TextField("Code", text: $viewModel.roomCode )
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
                .padding()
                
                TTRButton(action: {}, text: "Create", icon: "plus", bgColor: .green)
                    .frame(height: 50)
                
                TTRButton(action: {}, text: "Back", icon: "chevron.left", bgColor: .blue)
                    .frame(height: 50)
            }
        }
    }
}

#Preview {
    NewRoomView()
}
