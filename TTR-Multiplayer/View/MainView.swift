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
    
    private var tickets : [DestinationCardItem] = [DestinationCardItem(id: 0, origin: "Los Angeles", destination: "New York", point: 21),DestinationCardItem(id: 1, origin: "Toronto", destination: "Denver", point: 18),DestinationCardItem(id: 2, origin: "Chicago", destination: "Las Vegas", point: 14),DestinationCardItem(id: 3, origin: "San Francisco", destination: "Atlanta", point: 17)]
    
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
                                            ForEach(viewModel.playerCache.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                                VStack{
                                                    AsyncImage(url: URL(string: value.photoURL)) { image in
                                                        image
                                                            .resizable()
                                                            .frame(width: 60,height: 60)
                                                            .aspectRatio(contentMode: .fill)
                                                            .clipShape(.circle)
                                                            .padding(5)
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                    
                                                    Text(value.player.fullName)
                                                        .font(.system(size: 10))
                                                }
                                            }
                                            Spacer()
                                        }
                                    }.frame(maxWidth:.infinity,maxHeight:150)
                                    
                                    Spacer()
                                    
                                    if let room = viewModel.currentRoom {
                                       
                                        Text("Room \(room.roomCode)").foregroundColor(.red)
                                        HStack {
                                            Spacer()
                                            RoundedTTRButton(action: {
                                                viewModel.pickDestinationTickets()
                                            }, title: "Tickets", icon: "lanyardcard.fill", bgColor: .blue)
                                            
                                            if let player = viewModel.player {
                                                if room.ownerID == player.id {
                                                    RoundedTTRButton(action: {
                                                        viewModel.closeCurrentRoom()
                                                    }, title: "End", icon: "flag.checkered", bgColor: .red)
                                                } else {
                                                    RoundedTTRButton(action: {
                                                        viewModel.quitRoom()
                                                    }, title: "Quit", icon: "arrowshape.backward.fill", bgColor: .red)
                                                }
                                            }
                                            Spacer()
                                        }
                                        Spacer()
                                        
                                        VStack{
                                            HStack{
                                                Image(systemName: "calendar.day.timeline.left")
                                                    .font(.system(.title3))
                                                Text("Timeline")
                                                    .multilineTextAlignment(.leading)
                                                    .font(.system(.title3))
                                            }
                                            .padding(.leading,10)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            Divider()
                                            ScrollView {
                                                ForEach (viewModel.timeline) { item in
                                                    HStack {
                                                        if viewModel.playerCache.keys.contains(item.creatorID) {
                                                            let playerModel = viewModel.playerCache[item.creatorID]!
                                                            
                                                            AsyncImage(url: URL(string: playerModel.photoURL)) { image in
                                                                image
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fill)
                                                                    .clipShape(.circle)
                                                            } placeholder: {
                                                                ProgressView()
                                                            }
                                                            .padding([.leading,.trailing],3)
                                                            .frame(width: 25,height: 25)
                                                                
                                                            
                                                        } else {
                                                            Image("User")
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .clipShape(.circle)
                                                                .padding([.leading,.trailing],3)
                                                                .frame(width: 25,height: 25)
                                                        }
                                                        
                                                        let time = getTimeSring(interval: item.datetime)
                                                        
                                                        Text("\(time)")
                                                            .frame(width: 60 , alignment:.leading)
                                                            .padding(.leading,10)
                                                            .font(.system(size: 12,weight:.regular,design:.rounded))
                                                            .multilineTextAlignment(.leading)
                                                            .foregroundColor(.gray)
                                                        
                                                        Text("\(item.description)")
                                                            .frame(width:getScreenSize().width - 120, alignment:.leading)
                                                            .font(.system(size: 12,weight:.semibold))
                                                            .multilineTextAlignment(.leading)
                                                        Spacer()
                                                    }
                                                }
                                            }
                                            .padding()
                                            .frame(width:getScreenSize().width,alignment:.leading)
                                        }
                                        .padding(5)
                                        .frame(width:getScreenSize().width,height:300,alignment:.leading)
                                        .padding(5)
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
                .onChange(of: showMenu) { newValue in
                    if showMenu && offset == 0 {
                        offset = sideBarWidth
                        lastOffset = offset
                    }
                    
                    if !showMenu && offset == sideBarWidth {
                        offset = 0
                        lastOffset = 0
                    }
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
    
    private func getTimeSring(interval: TimeInterval) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let currentDate = Date(timeIntervalSince1970: interval)
        return dateFormatter.string(from: currentDate)
    }
}

#Preview {
    MainView()
}
