//
//  TTRButton.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import SwiftUI

struct TTRButton: View {
    @State var action : () -> Void
    @State var text : String = ""
    @State var icon : String = ""
    @State var bgColor : Color = .blue
    @State var fgColor : Color = .white
    var body: some View {
        Button(action: {
            action()
        }, label: {
            ZStack{
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(bgColor)
                
                    Label(text, systemImage: icon)
                        .foregroundColor(fgColor)
                }
                
            }
            
        )
    }
}

#Preview {
    TTRButton(action: {},text: "Login", icon: "key")
}
