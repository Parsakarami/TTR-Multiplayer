//
//  RoomService.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-04.
//

import Foundation
import FirebaseFirestore

class RoomService {
    static var instance = RoomService()
    private var roomCollection : CollectionReference
    
    init() {
        let db = Firestore.firestore()
        roomCollection = db.collection("rooms")
    }
    
    func isRoomInUsed(code: String) async throws -> Bool
    {
        let snapShots = try await roomCollection
            .whereField("roomCode", isEqualTo: code)
            .whereField("inUsed", isEqualTo: true)
            .getDocuments()
        
        return !snapShots.isEmpty
    }
    
    public func closeRoom(roomCode: String) {
        let userid = PlayerService.instance.player?.id
        
    }
    
    public func joinRoom(roomCode: String) {
        
    }
    
    public func fetchActiveRoom(userId: String) async throws -> Room? {
        let snapShot = try await roomCollection
            .whereField("ownerID", isEqualTo: userId)
            .whereField("inUsed", isEqualTo: true)
            .getDocuments()
        
        var room : Room? = nil
        if !snapShot.isEmpty{
            for doc in snapShot.documents {
                room = try doc.data(as: Room.self)
                break
            }
        }
        
        return room
    }
    
    public func fetchRooms(userId: String) async throws -> [Room] {
        let snapShot = try await roomCollection
            .whereField("ownerID", isEqualTo: userId)
            .getDocuments()
        
        var rooms : [Room] = []
        if !snapShot.isEmpty{
            for doc in snapShot.documents {
                let room = try doc.data(as: Room.self)
                rooms.append(room)
            }
        }
        
        return rooms
    }
}
