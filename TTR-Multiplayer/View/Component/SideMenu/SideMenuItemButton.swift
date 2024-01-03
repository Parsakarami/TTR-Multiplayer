//
//  SideMenuItemButton.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-03.
//

import SwiftUI

struct SideMenuItemButton: View {
    @State var text: String = "Parsa"
    @State var icon: String = "home"
    @State var action : () -> Void
    var body: some View {
        Button(action: action) {
            HStack{
                Image(systemName: icon)
                    .padding(.trailing,4)
                    .frame(width: 35)
                Text("**\(text)**")
            }.foregroundColor(.white)
                .frame(alignment: .leading)
                .padding([.top,.bottom],15)
                .font(.system(size: 18))
        }
    }
}

#Preview {
    SideMenuItemButton(action: {})
}
