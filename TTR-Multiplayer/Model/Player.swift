//
//  User.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import Foundation

struct Player:Codable {
    let id: String
    let fullName: String
    let email: String
    let joinedDate: TimeInterval
}
