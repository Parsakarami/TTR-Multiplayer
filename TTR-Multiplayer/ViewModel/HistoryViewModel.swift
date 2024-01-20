//
//  HistoryViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-20.
//

import Foundation

class HistoryViewModel : ObservableObject {
    @Published var history : [History] = []
    @Published var selectedHistory : History?
    init(){
        Task {
            guard let player = PlayerService.instance.player else {
                return
            }
            
            history = try await RoomService.instance.getHistory(pid: player.id)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                for var record in self.history {
                    var playerNames : [String:String] = [:]
                    for pid in record.playersPoints.keys {
                        if let player = PlayerService.instance.playersCache[pid] {
                            playerNames[pid] = player.player.fullName
                        }
                    }
                    record.playersNames = playerNames
                }
            }
        }
    }
}
