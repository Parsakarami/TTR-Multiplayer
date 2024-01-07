//
//  ContentView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-01.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @State var showMenu : Bool = false
    @State var offset : CGFloat = 0
    @State var lastOffset : CGFloat = 0
    @State private var isLoaded : Bool = false
    var body: some View {
        let sideBarWidth = getScreenSize().width - 120
        
        if !isLoaded {
            SplashScreen(isLoaded: $isLoaded)
        } else {
            if !viewModel.isAuthorized {
                LoginView()
            } else {
                NavigationView{
                    ZStack (alignment: Alignment(horizontal: .center, vertical: .top)) {
                        SideMenu(isShowMenu: $showMenu, player:$viewModel.player, currentRoom: $viewModel.currentRoom, profilePhoto: $viewModel.profilePhoto, sideBarWidth: sideBarWidth).zIndex(2)
                        //Main TabBar
                        VStack {
                            TabView{
                                
                                VStack(alignment: .center, spacing: 20){
                                    Button(action: {
                                        withAnimation(.smooth(duration: 0.3)){
                                            showMenu.toggle()
                                        }
                                    }){
                                            AsyncImage(url: URL(string: viewModel.profilePhoto)) { image in
                                                image
                                                    .resizable()
                                                    .frame(width: 50,height: 50)
                                                    .aspectRatio(contentMode: .fill)
                                                    .clipShape(.circle)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                    }
                                    
                                    Spacer()
                                    CardView()
                                    Spacer()
                                    
                                    if let room = viewModel.currentRoom {
                                        Text(room.roomCode).foregroundColor(.red)
                                        
                                        TTRButton(action: {
                                            viewModel.closeCurrentRoom()
                                        }, text: "End the room", icon: "xmark", bgColor: .red, fgColor: .white)
                                        .frame(width: 200, height: 50, alignment: .center)
                                    }
                                }
                                .tabItem {
                                    Label("Board",systemImage: "gamecontroller.fill")
                                }
                            }
                            .padding()
                            Spacer()
                        }
                        .zIndex(1)
                        .overlay{
                            Rectangle()
                                .fill(Color.primary.opacity(Double((offset / sideBarWidth) / 10)))
                                .ignoresSafeArea(.container,edges: .vertical)
                                .onTapGesture{
                                    withAnimation(.snappy){
                                        showMenu.toggle()
                                    }
                                }
                        }.zIndex(2)
                    }
                    .onAppear{
                        showMenu = false
                    }.ignoresSafeArea(.all)
                }.onChange(of: showMenu) { newValue in
                    if showMenu && offset == 0 {
                        offset = sideBarWidth
                        lastOffset = offset
                    }
                    
                    if !showMenu && offset == sideBarWidth {
                        offset = 0
                        lastOffset = 0
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}
