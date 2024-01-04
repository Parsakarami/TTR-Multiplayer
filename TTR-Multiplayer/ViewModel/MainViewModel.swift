//
//  MainViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MainViewModel : ObservableObject {
    @Published var player : Player? = nil
    @Published var isAuthorized : Bool = false
    private var handler: AuthStateDidChangeListenerHandle?
    
    init(){
        subscribeToAuthChange()
        self.isAuthorized = PlayerService.instance.isSignedIn
    }
    
    private func subscribeToAuthChange(){
        
        NotificationCenter.default.addObserver(
            forName: .playerAuthStatusChanged,
            object: nil,
            queue: .main) { notification in
            let status = notification.object as? authStatus
            if status == .authorized {
                self.player = PlayerService.instance.player
                self.isAuthorized = true
            } else {
                self.player = nil
                self.isAuthorized = false
            }
        }
        
    }
}
