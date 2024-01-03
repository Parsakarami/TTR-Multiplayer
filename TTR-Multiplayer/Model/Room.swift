//
//  Room.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-03.
//

import Foundation

struct Room : Codable {
    let ownerID : String
    let capacity : Int
    let winner : String?
    let createdDateTime : TimeInterval
}
