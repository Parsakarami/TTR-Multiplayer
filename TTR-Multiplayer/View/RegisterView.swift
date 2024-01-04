//
//  RegisterView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = RegisterViewModel()
    @State private var isInitialized = false
    @State private var isKeyboardOpened = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .center){
                Spacer()
                if !isKeyboardOpened {
                    AnimatedHeader()
                    .opacity(isKeyboardOpened ? 0 : 1)
                    .scaleEffect(isKeyboardOpened ? 0 : 1)
                    .animation(.snappy(duration: 0.2), value: isKeyboardOpened)
                    .frame(width: 150,height: 150)
                    .padding(.top,20)
                    VStack (spacing:0){
                        Text("Don't have an account?")
                            .font(.title2)
                            .padding(.top,25)
                        Text("Fill the form, and register now!")
                            .font(.body)
                    }
                    .offset(y:-10)
                }
                Spacer()
                        Form {
                            
                            if viewModel.errorMessage != "" {
                                Text(viewModel.errorMessage)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                            
                            TextField("Full Name", text: $viewModel.fullName )
                                .padding()
                                .cornerRadius(6)
                            
                            TextField("Email", text: $viewModel.email )
                                .padding()
                                .cornerRadius(6)
                            
                            SecureField("Password", text: $viewModel.password)
                                .padding()
                                .cornerRadius(6)
                            
                            TTRButton(action: { viewModel.register() }, text: "Sign up", icon: "pencil", bgColor: .green)
                                .frame(height: 50)
                                .padding(5)
                            
                            TTRButton(action: { dismiss() }, text: "Close", icon: "xmark", bgColor: .red)
                                .frame(height: 50)
                                .padding(5)
                        }
                        .cornerRadius(8)
                Spacer()
                Spacer()
            }
            .sheet(isPresented: .constant(viewModel.dismissTheRegisterSheet), content: {
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
    RegisterView()
}
