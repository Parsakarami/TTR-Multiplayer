//
//  History.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-20.
//

import Foundation

struct History : Identifiable {
    let id : String
    let roomId : String
    let winner : String
    let datetime : TimeInterval
    var playersPoints : [String:Int]
    var playersTickets : [String:[GameDestinationCard]]
    var playersNames : [String:String]?
}
