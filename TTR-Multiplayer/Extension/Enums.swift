//
//  Enums.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-04.
//

import Foundation

enum playerStatus {
    case authorized
    case notAuthorized
    case profileUpdated
}

enum roomStatus {
    case created
    case playerJoined
    case playerLeft
    case quited
    case changed
    case closed
    case deleted
    case fetchedCurrentRoom
}

enum roomTimelineEventType : String {
    case started
    case playerJoined
    case playerRequestedTickets
    case playerQuit
    case playerPickedTickets
    case closed
    case finished
}

