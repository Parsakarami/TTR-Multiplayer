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
    @State var showMyDestinations : Bool = false
    @State var showClaim : Bool = false
    @State var showConfirmationDialoge : Bool = false
    @State var showPickTicketDialoge : Bool = false
    @State var showTimeline : Bool = true
    @State var imageCache : [String:UIImage] = [:]
    
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
                                    if viewModel.currentRoom != nil {
                                        Text("Room \(viewModel.currentRoom!.roomCode)")
                                            .font(.system(.headline))
                                            .foregroundColor(.black)
                                            .frame(height: 30, alignment: .center)
                                            .padding([.leading,.trailing],40)
                                            .background(.green)
                                            .clipShape(.capsule)
                                        
                                        HStack (alignment: .center, spacing: 10) {
                                            
                                            Spacer()
                                            //ForEach(viewModel.playerCache.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                            ForEach(viewModel.currentRoom!.playersIDs, id: \.self) { id in
                                                if let value = viewModel.playerCache[id] {
                                                    VStack{
                                                        ZStack (alignment: .topTrailing) {
                                                            Image(uiImage: getImage(uid: id))
                                                                .resizable()
                                                                .frame(width: 60,height: 60)
                                                                .aspectRatio(contentMode: .fill)
                                                                .clipShape(.circle)
                                                                .padding(5)
                                                            
                                                            if let numberOfTickers = viewModel.playersTicketCounts[id] { 
                                                                ZStack (alignment: .center) {
                                                                    Circle()
                                                                        .fill(.blue)
                                                                        .shadow(radius: 1, x: -1, y: 1)
                                                                    
                                                                    Text(String(numberOfTickers))
                                                                        .font(.system(.body))
                                                                        .foregroundStyle(.white)
                                                                    
                                                                }
                                                                .frame(width: 25, height: 25)
                                                            }
                                                        }
                                                        
                                                        Text(value.player.fullName)
                                                            .font(.system(.subheadline))
                                                    }
                                                }
                                            }
                                            Spacer()
                                        }.frame(maxWidth:.infinity,maxHeight:100)
                                    }
                                    
                                    if let room = viewModel.currentRoom {
                                        HStack (spacing:0) {
                                            Spacer()
                                            
                                            RoundedTTRButton(action: {
                                                withAnimation(.snappy){
                                                    showClaim.toggle()
                                                }
                                            }, title: "Claim", icon: "map.fill", bgColor: .cyan, fgColor: .cyan)
                                            
                                            
                                            RoundedTTRButton(action: { showPickTicketDialoge = true },
                                                             title: "Pick",
                                                             icon: "rectangle.stack.badge.plus",
                                                             bgColor: room.inUsed ?  .blue : .gray,
                                                             fgColor: room.inUsed ? .blue : .gray)
                                            .alert("You must pick at least a card from the given cards. Do you want to continue?", isPresented: $showPickTicketDialoge) {
                                                Button("Yes", role:.destructive) {
                                                    viewModel.pickDestinationTickets()
                                                    showPickTicketDialoge = false
                                                }
                                            }
                                            
                                            RoundedTTRButton(action: {
                                                withAnimation(.snappy){
                                                    showTimeline.toggle()
                                                }
                                            }, title: "Event", icon: "clock.arrow.circlepath", bgColor: .indigo, fgColor: .indigo)
                                            
                                            RoundedTTRButton(action: {
                                                showMyDestinations = true
                                            }, title: "Mine", icon: "square.stack.3d.up.fill", bgColor: .mint, fgColor: .mint)
                                            
                                            if let player = viewModel.player {
                                                if room.ownerID == player.id {
                                                    RoundedTTRButton(action: {showConfirmationDialoge = true},
                                                                     title: "End",
                                                                     icon: "flag.fill",
                                                                     bgColor: .red,
                                                                     fgColor: .red)
                                                    .alert("Are you sure?", isPresented: $showConfirmationDialoge) {
                                                        Button("Yes", role:.destructive) {
                                                            viewModel.closeCurrentRoom()
                                                            showConfirmationDialoge = false
                                                        }
                                                    }
                                                } else {
                                                    RoundedTTRButton(action: {showConfirmationDialoge = true},
                                                                     title: "Quit",
                                                                     icon: "arrowshape.turn.up.left.fill",
                                                                     bgColor: .red,
                                                                     fgColor: .red)
                                                    .alert("Are you sure?", isPresented: $showConfirmationDialoge) {
                                                        Button("Yes", role:.destructive) {
                                                            viewModel.quitRoom()
                                                            showConfirmationDialoge = false
                                                        }
                                                    }
                                                }
                                            }
                                            Spacer()
                                        }
                                        Spacer()
                                        
                                        VStack{
                                            if showTimeline {
                                                Divider()
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
                                                    ForEach (viewModel.timeline.reversed()) { item in
                                                        HStack {
                                                            Image(uiImage:getImage(uid: item.creatorID))
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .clipShape(.circle)
                                                                .padding([.leading,.trailing],3)
                                                                .frame(width: 25,height: 25)
                                                            
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
                                        }
                                        .padding(5)
                                        .frame(width:getScreenSize().width,height:320,alignment:.leading)
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
                    DestinationPickerView(cards: viewModel.playerThreeTickets, sheetDismisser: $viewModel.showDestinationPicker)
                        .interactiveDismissDisabled()
                }
                .sheet(isPresented: $showMyDestinations) {
                    CurrentDestinationsView(
                        playerCurrentTickets: .constant(RoomService.instance.playerCurrentTickets)
                    )
                }
                .sheet(isPresented: $showClaim) {
                    ClaimPointsView()
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
    
    private func getImage(uid: String) -> UIImage {
        var result = UIImage(imageLiteralResourceName: "User")
        guard let data = StorageService.instance.playerImageCache[uid] else {
            return result
        }
        
        if let UIImage = UIImage(data:data) {
            result = UIImage
        }
        
        return result
    }
}

#Preview {
    MainView()
}
