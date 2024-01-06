//
//  TTR_MultiplayerApp.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-01.
//

import SwiftUI
import FirebaseCore

@main
struct TTR_MultiplayerApp: App {
    init(){
        FirebaseApp.configure()
        
        //Init services
        StorageService.instance.initialize()
        PlayerService.instance.initialize()
        RoomService.instance.initialize()
        
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
