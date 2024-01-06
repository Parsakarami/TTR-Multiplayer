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
    @Published var currentRoom : Room? = nil
    @Published var profilePhoto : String = ""
    private var handler: AuthStateDidChangeListenerHandle?
    
    init() {
        subscribeToAuthChange()
        subscribeToRoomChange()
    }
    
    func closeCurrentRoom() {
        RoomService.instance.closeCurrentRoom()
    }
    
    private func subscribeToAuthChange(){
        NotificationCenter.default.addObserver(
            forName: .playerAuthStatusChanged,
            object: nil,
            queue: .main) { [weak self] notification in
                let status = notification.object as? playerStatus
                if status == .authorized {
                    self?.player = PlayerService.instance.player
                    self?.isAuthorized = true
                    self?.profilePhoto = PlayerService.instance.playerProfilePhoto
                } else if status == .profileUpdated {
                    self?.profilePhoto = PlayerService.instance.playerProfilePhoto
                } else {
                    self?.player = nil
                    self?.isAuthorized = false
                }
            }
        
    }
    
    private func subscribeToRoomChange(){
        NotificationCenter.default.addObserver(
            forName: .roomStatusChanged,
            object: nil,
            queue: .main) { [weak self] notification in
                let status = notification.object as? roomStatus
                if status == .fetchedCurrentRoom || status == .created {
                    self?.currentRoom = RoomService.instance.currentRoom
                } else if status == .closed {
                    self?.currentRoom = nil
                }
            }
        
    }
}
