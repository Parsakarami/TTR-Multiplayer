//
//  LoginView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    var body: some View {
        ZStack{
            VStack(alignment: .center){
                VStack{
                    Text("Header")
                }
                Spacer()
                Spacer()
                VStack{
                        Form{
                            TextField("Email", text: $viewModel.email )
                                .padding()
                                .cornerRadius(6)
                            
                            TextField("Password", text: $viewModel.password)
                                .padding()
                                .cornerRadius(6)
                            
                            TTRButton(action: {}, text: "Login", icon: "key")
                                .padding([.top,.bottom],20)
                            
                        }.padding()
                }
                .cornerRadius(8)
                .frame(width: getScreenSize().width, height: 350, alignment: .center)
                
                VStack{
                    Text("New around here?")
                    NavigationLink("Create an account",destination: {})
                        .foregroundColor(.blue)
                }
            }
            .frame(alignment: .center)
            .padding()
            .background(.white)
            
        }
        .frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .background(.blue)
    }
}

#Preview {
    LoginView()
}
