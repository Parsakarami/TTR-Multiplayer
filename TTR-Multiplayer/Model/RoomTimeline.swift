//
//  RoomTimeline.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-07.
//

import Foundation

struct RoomTimeline : Identifiable, Codable {
    let id : String
    let roomID : String
    let creatorID : String
    let datetime : TimeInterval
    let eventType : String
}
