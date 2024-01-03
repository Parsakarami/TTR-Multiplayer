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
    @State var isShowLoginForm : Bool = true
    @State private var timer : Timer?
    @State private var isLoaded : Bool = false
    var body: some View {
        let sideBarWidth = getScreenSize().width - 120
        if isLoaded {
            NavigationView{
                ZStack (alignment: Alignment(horizontal: .center, vertical: .top)) {
                    SideMenu(isShowMenu: $showMenu,sideBarWidth: sideBarWidth).zIndex(2)
                    //Main TabBar
                    VStack {
                        TabView{
                            
                            VStack(alignment: .center, spacing: 20){
                                Button(action: {
                                    withAnimation(.smooth(duration: 0.3)){
                                        showMenu.toggle()
                                    }
                                }){
                                    Image("User")
                                        .resizable()
                                        .frame(width: 50,height: 50)
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(.circle)
                                }
                            }
                            .tabItem {
                                Label("Board",systemImage: "gamecontroller.fill")
                            }
                            
                            VStack(alignment: .center, spacing: 20){
                                
                            }
                            .tabItem {
                                Label("Profile",systemImage: "gear")
                            }
                        }
                        .padding()
                        Spacer()
                    }
                    .zIndex(1)
                    .overlay{
                        Rectangle()
                            .fill(Color.primary.opacity(Double((offset / sideBarWidth) / 5)))
                            .ignoresSafeArea(.container,edges: .vertical)
                            .onTapGesture{
                                withAnimation(.snappy(duration: 0.3)){
                                    showMenu.toggle()
                                }
                            }
                    }.zIndex(2)
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
                refreshUserAuth()
            }
            .onAppear{
                if timer == nil {
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                        refreshUserAuth()
                    }
                }
            }
            .sheet(isPresented: $isShowLoginForm, content: {
                LoginView(isAuthorized: $isShowLoginForm)
                    .interactiveDismissDisabled()
            })
            
        } else {
            SplashScreen(isLoaded: $isLoaded)
        }
    }
    
    private func refreshUserAuth(){
        isShowLoginForm = !(viewModel.isSignedIn && !viewModel.currentUserId.isEmpty)
    }
}

#Preview {
    MainView()
}
