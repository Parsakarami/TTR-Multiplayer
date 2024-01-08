//
//  Room.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-03.
//

import Foundation

struct Room : Codable {
    let id: String
    let ownerID : String
    let roomCode : String
    let capacity : Int
    let inUsed : Bool
    let winner : String?
    let createdDateTime : TimeInterval
    var playersIDs : [String]
}
