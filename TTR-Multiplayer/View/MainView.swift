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
    @State var isShowLoginForm : Bool = false
    @State private var timer : Timer?
    var body: some View {
        let sideBarWidth = getScreenSize().width - 120
        NavigationView{
            ZStack{
                SideMenu(isShowMenu: $showMenu,sideBarWidth: sideBarWidth).zIndex(2)
                //Main TabBar
                VStack {
                    Spacer()
                    TabView{
                        VStack(alignment: .center, spacing: 20){
                            Button(action: {
                                withAnimation(.smooth(duration: 0.3)){
                                    showMenu.toggle()
                                }
                            }){
                                Text("Show Menu")
                                    .foregroundColor(.white)
                                    .padding(15)
                                    .frame(width: 200)
                                    .background(.green)
                            }
                            
                            Text(viewModel.currentUserId)
                            
                            Text(viewModel.isSignedIn ? "Atuhorized!" : "Not Atuhorized!")
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
                        .fill(Color.primary.opacity(Double((offset / sideBarWidth) / 5)))
                        .ignoresSafeArea(.container,edges: .vertical)
                        .onTapGesture{
                            withAnimation(.snappy(duration: 0.3)){
                                showMenu.toggle()
                            }
                        }
                }
            }.ignoresSafeArea(.container)
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
            refreshUserAuth()
            if timer == nil {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                   refreshUserAuth()
                }
            }
        }.sheet(isPresented: $isShowLoginForm, content: {
                LoginView(isAuthorized: $isShowLoginForm)
                .interactiveDismissDisabled()
        })
    }
    
    private func refreshUserAuth(){
        isShowLoginForm = !(viewModel.isSignedIn && !viewModel.currentUserId.isEmpty)
    }
}

#Preview {
    MainView()
}
