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
    public private(set) var currentRoom : Room?
    
    init() {
        let db = Firestore.firestore()
        roomCollection = db.collection("rooms")
        NotificationCenter.default.addObserver(forName: .playerAuthStatusChanged,
                                               object: nil,
                                               queue: .main) { [self] notification in
            let status = notification.object as? playerStatus
            if status == .authorized {
                let pid = PlayerService.instance.player?.id ?? ""
                guard pid != "" else {
                    return
                }
                
                Task(priority:.high) {
                    self.currentRoom = try await fetchActiveRoom(pid: pid)
                    NotificationCenter.default.post(name: .roomStatusChanged, object: roomStatus.fetchedCurrentRoom)
                }
            }
        }
    }
    
    func initialize() {
        
    }
    
    func isRoomInUsed(code: String) async throws -> Bool
    {
        let snapShots = try await roomCollection
            .whereField("roomCode", isEqualTo: code)
            .whereField("inUsed", isEqualTo: true)
            .getDocuments()
        
        return !snapShots.isEmpty
    }
    
    public func closeCurrentRoom(completion: ((Result<Bool,Error>) -> Void)? = nil) {
        guard let room = currentRoom else {
            return
        }
        
        closeRoom(id:room.id) { [weak self] result in
            do {
                let wasSuccessful = try result.get()
                if wasSuccessful {
                    self?.currentRoom = nil
                    completion?(.success(true))
                } else {
                    let error = NSError(domain: "RoomService.closeCurrentRoom", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to close the room."])
                    completion?(.failure(error))
                }
            } catch {
                completion?(.failure(error))
            }
        }
    }
    
    public func quitRoom(id: String) {
        guard let room = currentRoom else {
            return
        }
        
        var currentPlayersIDs = room.playersIDs
        currentPlayersIDs.removeAll{ $0 == id}
        roomCollection.document(room.id).updateData(["playersIDs" : currentPlayersIDs, "capacity": room.capacity + 1]) { [weak self] error in
            guard error == nil else {
                return
            }
            self?.currentRoom = nil
            NotificationCenter.default.post(name: .roomStatusChanged, object: roomStatus.quited)
        }
    }
    
    private func closeRoom(id: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        roomCollection.document(id).updateData([
            "inUsed" : false
        ]) { error in
            if let error = error {
                completion(.failure(error))
            }
            completion(.success(true))
            NotificationCenter.default.post(name: .roomStatusChanged, object: roomStatus.closed)
        }
    }
    
    public func addRoom(room: Room, player: Player) async throws -> Bool {
        let isInUsed = try await RoomService.instance.isRoomInUsed(code: room.roomCode)
        if !isInUsed {
            do {
                try await roomCollection.document(room.id)
                    .setData(room.asDictionary())
                currentRoom = room
                listenToRoomDataChange(id:room.id)
                NotificationCenter.default.post(name: .roomStatusChanged, object: roomStatus.created)
                return true
            } catch {
                return false
            }
        } else {
            return false
        }
    }
    
    public func joinRoom(roomCode: String) async throws -> Bool {
        guard roomCode.trimmingCharacters(in: .whitespaces) != "" else {
            return false
        }
        
        let snapShot = try await roomCollection
            .whereField("inUsed", isEqualTo: true)
            .getDocuments()
        
        if !snapShot.isEmpty{
            for doc in snapShot.documents {
                let result = try doc.data(as: Room.self)
                guard let player = PlayerService.instance.player else {
                    break
                }
                
                if result.ownerID != player.id && result.capacity > 0 {
                    
                    //Update room players and capacity
                    var newPlayerIDs: [String] = result.playersIDs
                    var newCapacity = result.capacity
                    let isNewPlayer = !newPlayerIDs.contains(player.id)
                    if isNewPlayer {
                        newPlayerIDs.append(player.id)
                        newCapacity -= 1
                        try await roomCollection.document(result.id).updateData(["capacity": newCapacity, "playersIDs":newPlayerIDs])
                    }
                    currentRoom = result
                    listenToRoomDataChange(id:result.id)
                    NotificationCenter.default.post(name: .roomStatusChanged, object: roomStatus.playerJoined)
                    return true
                }
                break
            }
        }
        return false
    }
    
    public func fetchActiveRoom(pid: String) async throws -> Room? {
        var room : Room? = nil
        
        guard pid.trimmingCharacters(in: .whitespaces) != "" else {
            return room
        }
        
        let snapShot = try await roomCollection
            .whereField("ownerID", isEqualTo: pid)
            .whereField("inUsed", isEqualTo: true)
            .getDocuments()
        
        if !snapShot.isEmpty{
            for doc in snapShot.documents {
                room = try doc.data(as: Room.self)
                break
            }
        }
        
        return room
    }
    
    public func fetchRooms(pid: String) async throws -> [Room] {
        var rooms : [Room] = []
        
        guard pid.trimmingCharacters(in: .whitespaces) != "" else {
            return rooms
        }
        
        let snapShot = try await roomCollection
            .whereField("ownerID", isEqualTo: pid)
            .getDocuments()
        
        if !snapShot.isEmpty{
            for doc in snapShot.documents {
                let room = try doc.data(as: Room.self)
                rooms.append(room)
            }
        }
        
        return rooms
    }
    
    private func listenToRoomDataChange(id: String) {
        guard !id.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        roomCollection.document(id).addSnapshotListener{ documentSnapshot,error in
            guard let doc = documentSnapshot else {
                return
            }
            
            do {
                self.currentRoom = try doc.data(as: Room.self)
                NotificationCenter.default.post(name:.roomStatusChanged,object: roomStatus.changed)
            } catch {
                print(error)
            }
        }
    }
}
