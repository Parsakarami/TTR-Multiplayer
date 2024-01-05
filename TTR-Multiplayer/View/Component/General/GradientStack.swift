//
//  GradientStack.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-04.
//

import SwiftUI

struct GradientStack<Content: View>: View {
    let content: Content
    var colors : [Color]
    
    init(colors: [Color], @ViewBuilder content: () -> Content) {
        self.content = content()
        self.colors = colors
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors:colors),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
            content
        }
    }
}

#Preview {
    GradientStack(colors:[.blue,.black], content: {})
}
