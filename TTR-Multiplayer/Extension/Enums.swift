//
//  Enums.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-04.
//

import Foundation

enum authStatus {
    case authorized
    case notAuthorized
}

enum roomStatus {
    case created
    case playerJoined
    case playerLeft
    case closed
    case deleted
    case fetchedCurrentRoom
}

