//
//  SideMenu.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-01.
//

import SwiftUI
    
struct SideMenu: View {
    @Binding var isShowMenu : Bool
    @State var sideBarWidth : CGFloat
    var body: some View {
        VStack (alignment: .leading){
            HStack (alignment:.top){
                VStack(alignment: .leading){
                    Image("User")
                        .resizable()
                        .frame(width: 85,height: 85)
                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        .clipShape(.circle)
                    Text("Parsa Karami")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .padding(.top,10)
    //                    Divider()
    //                    .background(Rectangle().foregroundColor(.white).frame(height: 2))
    //                    .frame(width: 150)
                }
                Spacer()
                Button(action: {
                    withAnimation(.smooth(duration: 0.3)){
                        isShowMenu = false
                    }
                }, label: {
                    Label("", systemImage: "chevron.right")
                        .foregroundColor(.white)
                })
                .padding()
            }
            .frame(width: sideBarWidth, height:200,alignment: .bottomLeading)
            //.background(.gray)
            
            VStack(alignment: .leading, spacing: 10) {
                SideMenuItem(text: "Home")
                SideMenuItem(text: "Create room")
                SideMenuItem(text: "Home")
                SideMenuItem(text: "Home")
                SideMenuItem(text: "Home")
            }
            .padding(.top,40)
            .frame(width: sideBarWidth,alignment: .leading)
            Spacer()
        }
        .frame(width: sideBarWidth, height: getScreenSize().height, alignment: .center)
        .padding(.leading, 20)
        .background(.blue)
        .frame(width: getScreenSize().width, height: getScreenSize().height, alignment: .leading)
        .offset(x: isShowMenu ? 0 : -getScreenSize().width)
        //test
        //.offset(x: 0)
    }
}

#Preview {
    SideMenu(isShowMenu: .constant(false),sideBarWidth: UIScreen.main.bounds.width - 120)
}
