//
//  LoginView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @State var isShown = true
    @State var images = ["Train","Train1","Train2","Train3"]
    @State var image = "Train3"
    @State private var lastRandom = 3
    @State private var timer : Timer?
    @State private var isShowRegisterForm = false
    @State private var isInitialized = false
    @State private var isKeyboardOpened = false
    var body: some View {
        ZStack{
            VStack(alignment: .center){
                if !isKeyboardOpened {
                    VStack (spacing: 10) {
                        Image(image)
                            .resizable()
                            .frame(width: 250,height: 250)
                            .opacity(isShown ? 1 : 0)
                            .animation(.spring(duration: 0.3), value: isShown)
                            .scaleEffect(isShown ? 1 : 0.9)
                            .rotationEffect(isShown ? .degrees(0) : .degrees(-15))
                        Text("Ticket to Ride")
                            .font(.title)
                            .padding(.top,10)
                    }
                    .opacity(isKeyboardOpened ? 0 : 1)
                    .scaleEffect(isKeyboardOpened ? 0 : 1)
                    .animation(.snappy(duration: 0.2), value: isKeyboardOpened)
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
                initAnimationTimer()
                if !isInitialized {
                    subscribeToKeyboard()
                    isInitialized = true
                }
            }
            .frame(alignment: .center)
            .padding()
        }
        .frame(alignment: .center)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: NavigationBackButton())
    }
        
    
    private func getUniqueRandomIndex() -> Int{
        var randomIndex = Int.random(in: 0...3)
        while (self.lastRandom == randomIndex) {
            randomIndex = Int.random(in: 0...3)
        }
        
        self.lastRandom = randomIndex
        return randomIndex
    }
    
    private func initAnimationTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { _ in
                withAnimation(.snappy) {
                    isShown = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6)
                {
                    image = images[getUniqueRandomIndex()]
                    withAnimation(.snappy){
                        isShown = true
                    }
                }
            }
        }
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
