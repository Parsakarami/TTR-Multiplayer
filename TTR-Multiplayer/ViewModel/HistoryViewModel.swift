//
//  HistoryViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-20.
//

import Foundation

class HistoryViewModel : ObservableObject {
    @Published var history : [History] = []
    
    init(){
        Task {
            guard let player = PlayerService.instance.player else {
                return
            }
            
            history = try await RoomService.instance.getHistory(pid: player.id)
        }
    }
}
