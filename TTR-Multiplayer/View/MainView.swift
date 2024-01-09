//
//  ContentView.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-01.
//

import SwiftUI
import FirebaseFirestoreSwift

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @State var showMenu : Bool = false
    @State var offset : CGFloat = 0
    @State var lastOffset : CGFloat = 0
    @State private var isLoaded : Bool = false
    
    private var tickets : [DestinationCardItem] = [DestinationCardItem(id: 0, origin: "Los Angeles", destination: "New York", point: 21),DestinationCardItem(id: 1, origin: "Toronto", destination: "Denver", point: 18),DestinationCardItem(id: 2, origin: "Chicago", destination: "Las Vegas", point: 14),DestinationCardItem(id: 3, origin: "San Francisco", destination: "Atlanta", point: 17)]
    
    //@FirestoreQuery(
       // collectionPath: "/rooms/1/timeline",predicates: []) var timeLineQuery : [RoomTimeline]
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
                                    HStack (alignment: .center, spacing: 10) {
                                        if viewModel.currentRoom != nil {
                                            Spacer()
                                            ForEach (viewModel.roomPlayersPhotos, id: \.self) { photoAddress in
                                                VStack{
                                                    AsyncImage(url: URL(string: photoAddress)) { image in
                                                        image
                                                            .resizable()
                                                            .frame(width: 60,height: 60)
                                                            .aspectRatio(contentMode: .fill)
                                                            .clipShape(.circle)
                                                            .padding(5)
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                    
                                                    Text("Player Name")
                                                        .font(.system(size: 10))
                                                }
                                            }
                                            Spacer()
                                        }
                                    }.frame(maxWidth:.infinity,maxHeight:150)
                                    
                                    Spacer()
                                    if let room = viewModel.currentRoom {
                                        Text("Room \(room.roomCode)").foregroundColor(.red)
                                        
                                        TTRButton(action: {
                                            viewModel.pickDestinationTickets()
                                        }, text: "Pick Destinations", icon: "lanyardcard.fill", bgColor: .blue, fgColor: .white)
                                        .frame(width: 200, height: 50, alignment: .center)
                                        
                                        if let player = viewModel.player {
                                            if room.ownerID == player.id {
                                                TTRButton(action: {
                                                    viewModel.closeCurrentRoom()
                                                }, text: "End the room", icon: "xmark", bgColor: .red, fgColor: .white)
                                                .frame(width: 200, height: 50, alignment: .center)
                                            } else {
                                                TTRButton(action: {
                                                    viewModel.quitRoom()
                                                }, text: "Quit", icon: "xmark", bgColor: .red, fgColor: .white)
                                                .frame(width: 200, height: 50, alignment: .center)
                                            }
                                        }
                                        Spacer()
//                                        ScrollView {
//                                            List(timeLineQuery) { item in
//                                                TimelineView()
//                                            }
//                                        }
                                        Spacer()
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
                }
                .onAppear{
                   
                }
                .onChange(of: showMenu) { newValue in
                    if showMenu && offset == 0 {
                        offset = sideBarWidth
                        lastOffset = offset
                    }
                    
                    if !showMenu && offset == sideBarWidth {
                        offset = 0
                        lastOffset = 0
                    }
                    
                    guard let room = viewModel.currentRoom else {
                        return
                    }
                    
                    //$timeLineQuery.path = "rooms/\(room.id)/timeline"
                }
                .gesture(DragGesture().onChanged({value in
                }).onEnded({value in
                    let width = value.translation.width
                    let startX = value.startLocation.x
                    withAnimation(.snappy(duration: 0.25)) {
                        if width > 150 && startX < 200 {
                            showMenu = true
                        } else if -(width) > 200 {
                            showMenu = false
                        }
                    }
                }))
                .sheet(isPresented: $viewModel.showDestinationPicker){
                    DestinationPickerCardView(cards: self.tickets)
                        .interactiveDismissDisabled()
                }
            }
        }
    }
}

#Preview {
    MainView()
}
