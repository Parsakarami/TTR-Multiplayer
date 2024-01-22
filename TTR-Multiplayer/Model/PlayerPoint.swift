//
//  PlayerPoint.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-21.
//

import Foundation

struct PlayerPoint : Identifiable, Codable {
    
    init(playerId: String) {
        self.id = UUID().uuidString
        self.pid = playerId
        self.totalPoint = 0
        self.isLongestPath = false
        self.allTickets = []
        self.claimedTickets = [:]
        self.claimedTrains = [:]
        //Initialized trains
        self.claimedTrains[1] = 0
        self.claimedTrains[2] = 0
        self.claimedTrains[3] = 0
        self.claimedTrains[4] = 0
        self.claimedTrains[5] = 0
        self.claimedTrains[6] = 0
    }
    
    let id : String
    let pid : String
    var totalPoint : Int
    var isLongestPath : Bool
    var allTickets : [GameDestinationCard]
    var claimedTickets : [String:Bool]
    var claimedTrains : [Int:Int]
}
