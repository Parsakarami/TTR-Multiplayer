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
    @State private var lastRandom = 0
    var body: some View {
        ZStack{
            VStack(alignment: .center){
                
                Spacer()
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
                        .padding(.top,20)
                }
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
            .onAppear{
                Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                    withAnimation(.snappy(duration: 0.5)){
                        isShown.toggle()
                    }
                    
                    if !isShown {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                            image = images[getUniqueRandomIndex()]
                        }
                    }
                }
            }
            .frame(alignment: .center)
            .padding()
            
        }
        .frame(alignment: .center)
    }
        
    
    private func getUniqueRandomIndex() -> Int{
        var randomIndex = Int.random(in: 0...3)
        while (self.lastRandom == randomIndex) {
            randomIndex = Int.random(in: 0...3)
        }
        
        self.lastRandom = randomIndex
        return randomIndex
    }
}

#Preview {
    LoginView()
}
