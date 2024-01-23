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
    init(){
        Task {
            guard let player = PlayerService.instance.player else {
                return
            }
            
            let result = try await RoomService.instance.getAllRooms(pid: player.id)
            history = result.sorted(by: {$0.createdDateTime > $1.createdDateTime})
            DispatchQueue.main.asyncAfter(deadline: .now()) {
//                for var room in self.history {
//                    var playerNames : [String:String] = [:]
//                    for item in room.playersPoints {
//                        if let player = PlayerService.instance.playersCache[item.pid] {
//                            playerNames[pid] = player.player.fullName
//                        }
//                    }
//                    record.playersNames = playerNames
//                }
            }
        }
    }
}
