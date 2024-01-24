//
//  HistoryViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-20.
//

import Foundation

class HistoryViewModel : ObservableObject {
    @Published var history : [Room] = []
    @Published var selectedHistory : Room?
    @Published var isLoaded : Bool = false
    init(){
        Task {
            guard let player = PlayerService.instance.player else {
                return
            }
            
            let result = try await RoomService.instance.getAllRooms(pid: player.id)
            
            var playerIDs : [String] = [player.id]
            //Get the list of all players in history
            for room in result {
                for playerID in room.playersIDs {
                    if !playerIDs.contains(where: {$0 == playerID}) {
                        playerIDs.append(playerID)
                    }
                }
            }
            //Update player information in playerCache
            for pid in playerIDs {
                await PlayerService.instance.addPlayerToCache(id: pid)
            }
            
            history = result.sorted(by: {$0.createdDateTime > $1.createdDateTime})
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isLoaded = true
            }
        }
    }
}
