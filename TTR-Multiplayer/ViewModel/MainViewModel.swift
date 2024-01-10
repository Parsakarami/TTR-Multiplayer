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
    @Published var showDestinationPicker : Bool = false
    @Published var playerCache : [String:PlayerModel] = [:]
    @Published var timeline : [RoomTimeline] = []
    
    private var handler: AuthStateDidChangeListenerHandle?
    init() {
        subscribeToAuthChange()
        subscribeToRoomChange()
        subscribeToRoomTimeline()
    }
    
    deinit{
        let x = 10
    }
    
    func pickDestinationTickets() {
        //Add to timeline
        showDestinationPicker = true
    }
    
    func closeCurrentRoom() {
        guard let room = currentRoom else {
            return
        }
        
        RoomService.instance.closeRoom(id: room.id) { [weak self] result in
            self?.currentRoom = nil
        }
    }
    
    func quitRoom() {
        guard let player = player else {
            return
        }
        
        RoomService.instance.quitRoom(player: player)
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
                    self?.updatePlayerCache()
                } else if status == .closed {
                    self?.currentRoom = nil
                    self?.timeline.removeAll()
                } else if status == .playerJoined {
                    self?.updatePlayerCache()
                } else if status == .changed {
                    self?.currentRoom = RoomService.instance.currentRoom
                    self?.updatePlayerCache()
                } else if status == .quited {
                    self?.currentRoom = nil
                    self?.timeline.removeAll()
                }
            }
    }
    
    private func subscribeToRoomTimeline(){
        NotificationCenter.default.addObserver(
            forName: .roomTimelineAdded,
            object: nil,
            queue: .main) { [weak self] arg in
                guard let newEvent = arg.object as? RoomTimeline else {
                    return
                }
                
                if ((self?.timeline.contains { $0.id == newEvent.id}) != nil) {
                    self?.timeline.append(newEvent)
                }
            }
    }
    
    private func updatePlayerCache() {
        guard let room = RoomService.instance.currentRoom else {
            return
        }
        
        currentRoom = room
        Task(priority: .medium) {
            for playerId in room.playersIDs {
                await PlayerService.instance.addPlayerToCache(id: playerId)
            }
        }
        //Update internal player cache from service
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.playerCache = PlayerService.instance.playersCache
        }
    }
}
