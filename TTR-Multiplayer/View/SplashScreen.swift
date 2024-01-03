//
//  SplashScreen.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-03.
//

import SwiftUI

struct SplashScreen: View {
    @Binding var isLoaded : Bool
    @State private var isShown : Bool = false
    var body: some View {
        VStack (spacing:0) {
            Image("Train3")
                .resizable()
                .frame(width: 150,height: 150,alignment: .center)
                .clipShape(.circle)
                .scaleEffect(isShown ? 1 : 0.7)
            Text("Tikcet To Ride")
                .font(isShown ? .title : .title2)
                .italic()
                .bold()
                .offset(y: isShown ? 20 : -10)
            Text("Destination extension")
                .font(.headline)
                .italic()
                .offset(y: isShown ? 20 : -10)
        }
        .opacity(isShown ? 1 : 0.1)
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.snappy(duration: 0.5)){
                    isShown = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.snappy(duration: 0.5)){
                        isLoaded = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreen(isLoaded: .constant(false))
}
