//
//  LoginView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @State private var isShowRegisterForm = false
    @State private var isInitialized = false
    @State private var isKeyboardOpened = false
    var body: some View {
        ZStack{
            VStack(alignment: .center){
                if !isKeyboardOpened {
                    AnimatedHeader()
                    .opacity(isKeyboardOpened ? 0 : 1)
                    .scaleEffect(isKeyboardOpened ? 0 : 1)
                    .animation(.snappy(duration: 0.2), value: isKeyboardOpened)
                    .padding(.top,20)
                    Text("Ticket to Ride")
                        .font(.title)
                        .padding(.top,10)
                }
                Spacer()
                        Form{
                            TextField("Email", text: $viewModel.email )
                                .padding()
                                .cornerRadius(6)
                            
                            SecureField("Password", text: $viewModel.password)
                                .padding()
                                .cornerRadius(6)
                            
                            TTRButton(action: {viewModel.login()}, text: "Login", icon: "key", bgColor: .blue)
                                .frame(height: 50)
                                .padding([.top,.bottom],15)
                        }
                        .cornerRadius(8)
                        .frame(height: 290)
                Spacer()
                VStack {
                    Text("New around here?")
                    Button(action: {
                        isShowRegisterForm = true
                    }){
                        Text("Create an account")
                            .foregroundColor(.blue)
                    }
                    .offset(y:5)
                }
                .opacity(isKeyboardOpened ? 0 : 1)
                .animation(.snappy(duration: 0.2), value: isKeyboardOpened)
            }
            .sheet(isPresented: $isShowRegisterForm, content: {
                RegisterView()
                    .interactiveDismissDisabled()
            })
            .onAppear{
                if !isInitialized {
                    subscribeToKeyboard()
                    isInitialized = true
                }
            }
            .frame(alignment: .center)
            .padding()
        }
        .frame(alignment: .center)
    }
    
    private func subscribeToKeyboard(){
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil,
                                               queue: .main) { notification in
            withAnimation(.snappy){
                isKeyboardOpened = true
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: .main) { notification in
            withAnimation(.snappy){
                isKeyboardOpened = false
            }
        }
    }
}

#Preview {
    LoginView()
}
