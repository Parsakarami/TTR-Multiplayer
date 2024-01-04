//
//  AnimatedHeader.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import SwiftUI

struct AnimatedHeader: View {
    @State private var isShown : Bool = true
    @State private var images = ["Train","Train1","Train2","Train3"]
    @State private var image = "Train3"
    @State private var isInitialized = false
    @State private var lastRandom = 3
    @State private var timer : Timer?
    var body: some View {
        VStack (spacing: 10) {
            Image(image)
                .resizable()
                .frame(maxWidth: 235,maxHeight:235)
                .opacity(isShown ? 1 : 0)
                .animation(.spring(duration: 0.3), value: isShown)
                .scaleEffect(isShown ? 1 : 0.9)
                .rotationEffect(isShown ? .degrees(0) : .degrees(-15))
        }
        .onAppear{
            if !isInitialized {
                initAnimationTimer()
                isInitialized = true
            }
        }
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
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
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
}

#Preview {
    AnimatedHeader()
}
