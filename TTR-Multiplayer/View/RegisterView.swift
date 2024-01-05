//
//  RegisterView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import SwiftUI
import PhotosUI
import Combine

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = RegisterViewModel()
    @State private var isInitialized = false
    @State private var isKeyboardOpened = false
    @State private var isImagePickerPresented = false
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
                    
                    if viewModel.message != "" {
                        Text(viewModel.message)
                            .foregroundColor(viewModel.isSuccessful ? .green : .red)
                            .padding()
                    }
                    
                    if let profile = viewModel.selectedImage {
                        HStack {
                            Spacer()
                            VStack {
                                Image(uiImage: profile)
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(.circle)
                                    .padding(10)
                                    .frame(width: 125, height: 125)
                            }
                            Spacer()
                        }
                    } else {
                        Button("Pick Photos") {
                            isImagePickerPresented.toggle()
                        }
                        .padding()
                        .sheet(isPresented: $isImagePickerPresented) {
                            PhotoPicker(selectedImage: $viewModel.selectedImage)
                        }
                    }
                    
                    TextField("Full Name", text: $viewModel.fullName )
                        .autocorrectionDisabled()
                        .padding()
                        .cornerRadius(6)
                    
                    TextField("Email", text: $viewModel.email )
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding()
                        .cornerRadius(6)
                    
                    SecureField("Password", text: $viewModel.password)
                        .autocorrectionDisabled()
                        .padding()
                        .cornerRadius(6)
                    
                    TTRButton(action: { viewModel.register() }, text: "Sign up", icon: "pencil", bgColor: viewModel.isSuccessful ? .gray : .green)
                        .disabled(viewModel.isSuccessful)
                        .frame(height: 50)
                        .padding(5)
                    
                    TTRButton(action: { dismiss() }, text: "Close", icon: "xmark", bgColor: .red)
                        .frame(height: 50)
                        .padding(5)
                }
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
