//
//  ContentView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack{
            VStack {
                Image(systemName: "checkmark")
                    .imageScale(.large)
                    .foregroundStyle(.green)
                    .padding()
                Text("Hello, world!")
            }
        .padding()
        }
    }
}

#Preview {
    ContentView()
}
