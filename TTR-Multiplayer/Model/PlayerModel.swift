//
//  PlayerModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-10.
//

import Foundation

struct PlayerModel : Identifiable, Codable {
    let id: String
    let player: Player
    let photoURL : String
}
