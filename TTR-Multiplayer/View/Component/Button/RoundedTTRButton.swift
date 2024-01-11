//
//  RoundedButton.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-10.
//

import SwiftUI

struct RoundedTTRButton: View {
    @State var action : () -> Void
    @State var title : String
    @State var icon : String
    @State var bgColor : Color = .blue
    @State var fgColor : Color = .blue
    var body: some View {
        Button(action: {action()}) {
            VStack{
                VStack{
                    Image(systemName: icon)
                        .resizable()
                        .padding(15)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 55)
                        .padding(2)
                }
                .tint(.white)
                .background(bgColor)
                .frame(width: 55,height: 55)
                .aspectRatio(contentMode: .fit)
                .clipShape(.circle)
                Text(title)
                    .foregroundColor(fgColor)
                    .font(.system(size: 12,weight:.bold))
                    .multilineTextAlignment(.center)
                    .padding([.top,.bottom],4)
            }
            .padding()
        }
        .frame(maxWidth:80)
    }
}

#Preview {
    RoundedTTRButton(action: {},title: "",icon: "")
}
