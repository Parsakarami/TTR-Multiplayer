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
    @Binding var currentRoom : Room?
    @Binding var profilePhoto : String
    @State var sideBarWidth : CGFloat
    var body: some View {
            VStack (alignment: .leading){
                HStack (alignment:.top){
                    VStack(alignment: .leading){
                        AsyncImage(url: URL(string: profilePhoto)) { image in
                            image.resizable()
                                .frame(width: 70,height: 70)
                                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                .clipShape(.circle)
                        } placeholder: {
                            ProgressView()
                        }
                        
                        Text(player?.fullName ?? "")
                            .font(.system(size: 22,weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .padding(.top,10)
                    }
                    Spacer()
                }
                .frame(width: sideBarWidth, height:200,alignment: .bottomLeading)
                //.background(.gray)
                VStack(alignment: .leading,spacing: 0) {
                    VStack(alignment: .leading){
                        SideMenuItemButton(text: "Board", icon: "gamecontroller.fill", action: {closeMenu()})
                        if (currentRoom == nil) {
                            SideMenuItemLink(text: "Create a room", icon: "house.fill", destination: getView(name: "new-room"))
                            
                            SideMenuItemLink(text: "Join a room", icon: "point.3.connected.trianglepath.dotted", destination: getView(name: "join-room"))
                        }
                        SideMenuItemLink(text: "History", icon: "chart.bar.doc.horizontal", destination: getView(name: "history"))
                        SideMenuItemLink(text: "Profile", icon: "gear", destination: getView(name: "profile"))
                        Spacer()
                    }
                    .frame(minHeight: 300)
                    .frame(alignment: .topLeading)
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
            .gesture(DragGesture().onChanged({value in
                
            }).onEnded({value in
                let width = value.translation.width
                withAnimation(.snappy(duration: 0.25)) {
                    if -(width) > 120 {
                        isShowMenu = false
                    }
                }
            }))
    }
    
    private func closeMenu() {
        withAnimation(.snappy){
            isShowMenu = false
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
        case "profile":
            return AnyView(ProfileView())
        case "history":
            return AnyView(HistoryView())
        default:
            return AnyView(MainView())
        }
    }
}

#Preview {
    SideMenu(isShowMenu: .constant(true),
             player:.constant(nil),
             currentRoom: .constant(nil),
             profilePhoto: .constant(""),
             sideBarWidth: UIScreen.main.bounds.width - 120)
}
