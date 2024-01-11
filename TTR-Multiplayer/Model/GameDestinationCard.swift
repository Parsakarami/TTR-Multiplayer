//
//  GameDestinationCard.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-10.
//

import Foundation

struct GameDestinationCard : Codable {
    
    init(destination : Destination) {
        id = UUID().uuidString
        origin = destination.origin
        self.destination = destination.destination
        point = destination.point
        userID = nil
        isSelected = nil
    }
    
    var id : String
    var origin: String
    var destination: String
    var point : Int
    var userID : String?
    var isSelected : Bool?
}
