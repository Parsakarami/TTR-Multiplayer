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
    @Binding var player : Player?
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
                        Text(player?.fullName ?? "")
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
                    SideMenuItemButton(text: "Board", icon: "gamecontroller.fill", action: {closeMenu()})
                    SideMenuItemLink(text: "Create a room", icon: "house.fill", destination: getView(name: "new-room"))
                    SideMenuItemLink(text: "Join a room", icon: "point.3.connected.trianglepath.dotted", destination: getView(name: "join-room"))
                    SideMenuItemButton(text: "History", icon: "chart.bar.doc.horizontal", action: {})
                    SideMenuItemButton(text: "Settings", icon: "gear", action: {})
                    if player != nil {
                        Spacer()
                        VStack (alignment: .leading) {
                            Spacer()
                            SideMenuItemButton(text:"Sign Out", icon:"arrow.left.square.fill", action: {
                                closeMenu()
                                PlayerService.instance.signOut()
                            })
                            Spacer()
                        }
                    }
                }
                .padding(.top,80)
                .frame(width: sideBarWidth,alignment: .leading)
                Spacer()
            }
            .frame(width: sideBarWidth,
                   height: getScreenSize().height,
                   alignment: .center)
            .padding(.leading, 20)
            .background(LinearGradient(gradient: Gradient(colors:[.blue,.black,.black]),
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing))
            .frame(width: getScreenSize().width,
                   height: getScreenSize().height,
                   alignment: .leading)
            .offset(x: isShowMenu ? 0 : -getScreenSize().width)
            //test
    }
    
    private func closeMenu() {
        withAnimation(.snappy){
            isShowMenu = false
        }
    }
    
    private func getActiveRoom() async {
        guard player != nil else {
            return
        }
        
        Task(priority: .high) {
            let room = try await RoomService.instance.fetchActiveRoom(userId: player?.id ?? "")
            let x = room?.capacity
        }
    }
    
    private func getView(name:String) -> AnyView {
        switch name {
        case "main": 
            return AnyView(MainView())
        case "new-room":
            return AnyView(NewRoomView())
        case "join-room":
            return AnyView(JoinRoomView())
        default:
            return AnyView(MainView())
        }
    }
}

#Preview {
    SideMenu(isShowMenu: .constant(true), player:.constant(nil), sideBarWidth: UIScreen.main.bounds.width - 120)
}
