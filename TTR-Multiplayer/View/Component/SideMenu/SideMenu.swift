//
//  SideMenu.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-01.
//

import SwiftUI
import FirebaseAuth
    
struct SideMenu: View {
    @Binding var isShowMenu : Bool
    @State var sideBarWidth : CGFloat 
    var body: some View {
        VStack (alignment: .leading){
            HStack (alignment:.top){
                VStack(alignment: .leading){
                    Image("User")
                        .resizable()
                        .frame(width: 70,height: 70)
                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        .clipShape(.circle)
                    Text("Parsa Karami")
                        .font(.system(size: 22,weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .padding(.top,10)
                }
                Spacer()
                Button(action: {
                    closeMenu()
                }, label: {
                    Label("", systemImage: "chevron.right")
                        .foregroundColor(.white)
                })
                .padding()
            }
            .frame(width: sideBarWidth, height:200,alignment: .bottomLeading)
            //.background(.gray)
            VStack(alignment: .leading, spacing: 0) {
                SideMenuItem(text: "Board")
                SideMenuItem(text: "Create a room")
                SideMenuItem(text: "Join a room")
                SideMenuItem(text: "History")
                SideMenuItem(text: "Settings")
                if Auth.auth().currentUser != nil {
                    Spacer()
                    VStack (alignment: .center) {
                        Spacer()
                        Button(action: {
                            try? Auth.auth().signOut()
                            closeMenu()
                        }){
                            Text("Sign Out")
                                .padding()
                                .foregroundStyle(.white)
                                .frame(width:150, alignment: .center)
                                .background(.orange)
                                .cornerRadius(8)
                                .offset(x:-10)
                        }
                        Spacer()
                    }
                    .padding()
                    .frame(width: sideBarWidth,height: 150)
                }
            }
            .padding(.top,80)
            .frame(width: sideBarWidth,alignment: .leading)
            Spacer()
        }
        .frame(width: sideBarWidth, height: getScreenSize().height, alignment: .center)
        .padding(.leading, 20)
        .background(.blue)
        .frame(width: getScreenSize().width, height: getScreenSize().height, alignment: .leading)
        .offset(x: isShowMenu ? 0 : -getScreenSize().width)
        //test
    }
    
    private func closeMenu() {
        withAnimation(.smooth(duration: 0.3)){
            isShowMenu = false
        }
    }
}

#Preview {
    SideMenu(isShowMenu: .constant(false),sideBarWidth: UIScreen.main.bounds.width - 120)
}
