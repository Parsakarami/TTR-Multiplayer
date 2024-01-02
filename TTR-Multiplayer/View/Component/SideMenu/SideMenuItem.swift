//
//  SideMenuItem.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-01.
//

import SwiftUI

struct SideMenuItem: View {
    @State var text: String = "Parsa"
    var body: some View {
        Text("**\(text)**")
            .foregroundColor(.white)
            .frame(alignment: .leading)
            .padding(.top,20)
            .padding(.bottom,20)
            .font(.system(size: 18))
    }
}

#Preview {
    SideMenuItem()
}