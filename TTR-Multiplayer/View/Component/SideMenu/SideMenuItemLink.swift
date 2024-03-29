//
//  SideMenuItem.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-01.
//

import SwiftUI

struct SideMenuItemLink: View {
    @State var text: String = "Parsa"
    @State var icon: String = "home"
    @State var destination : AnyView
    var body: some View {
        NavigationLink(destination: destination) {
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
