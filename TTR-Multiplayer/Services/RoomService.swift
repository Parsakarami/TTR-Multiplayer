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
    private var timelineCollection : CollectionReference
    public private(set) var currentRoom : Room?
    public private(set) var currentTimeline : [RoomTimeline] = []
    private var roomListener : ListenerRegistration? = nil
    private var timelineListener : ListenerRegistration? = nil
    
    init() {
        let db = Firestore.firestore()
        roomCollection = db.collection("rooms")
        timelineCollection = db.collection("timelines")
        
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
                    let result = try await fetchActiveRoom(pid: pid)
                    guard let room = result else {
                        return
                    }
                    self.currentRoom = room
                    self.listenToRoomDataChange(id:room.id)
                    self.listenToRoomTimelineDataChange(id: room.id)
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
                    self?.currentTimeline.removeAll()
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
    
    public func quitRoom(player: Player) {
        guard let room = currentRoom else {
            return
        }
        
        var currentPlayersIDs = room.playersIDs
        currentPlayersIDs.removeAll{ $0 == player.id}
        roomCollection.document(room.id).updateData(["playersIDs" : currentPlayersIDs, "capacity": room.capacity + 1]) { [weak self] error in
            guard error == nil else {
                return
            }
            self?.currentRoom = nil
            self?.currentTimeline.removeAll()
            NotificationCenter.default.post(name: .roomStatusChanged, object: roomStatus.quited)
        }
        
        Task {
            let newEvent = RoomTimeline(id: UUID().uuidString,
                                        roomID: room.id,
                                        creatorID: player.id,
                                        datetime: Date().timeIntervalSince1970,
                                        eventType: roomTimelineEventType.playerQuit.rawValue,
                                        description: "\(player.fullName) left the game.")
            
            try await self.addEventToRoomTimeline(timeline: newEvent)
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
                listenToRoomTimelineDataChange(id: room.id)
                
                let newEvent = RoomTimeline(id: UUID().uuidString,
                                            roomID: room.id,
                                            creatorID: player.id,
                                            datetime: Date().timeIntervalSince1970,
                                            eventType: roomTimelineEventType.started.rawValue,
                                            description: "The game has started.")
                try await addEventToRoomTimeline(timeline: newEvent)
                
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
                let room = try doc.data(as: Room.self)
                guard let player = PlayerService.instance.player else {
                    break
                }
                
                if room.ownerID != player.id && room.capacity > 0 {
                    
                    
                    listenToRoomDataChange(id:room.id)
                    listenToRoomTimelineDataChange(id: room.id)
                    
                    //Update room players and capacity
                    var newPlayerIDs: [String] = room.playersIDs
                    var newCapacity = room.capacity
                    let isNewPlayer = !newPlayerIDs.contains(player.id)
                    if isNewPlayer {
                        newPlayerIDs.append(player.id)
                        newCapacity -= 1
                        try await roomCollection.document(room.id).updateData(["capacity": newCapacity,
                                                                               "playersIDs":newPlayerIDs])
                        
                        //Add timeline event
                        let newEvent = RoomTimeline(id: UUID().uuidString,
                                                    roomID: room.id,
                                                    creatorID: player.id,
                                                    datetime: Date().timeIntervalSince1970,
                                                    eventType: roomTimelineEventType.playerJoined.rawValue,
                                                    description: "\(player.fullName) has joined to the game.")
                        
                        try await addEventToRoomTimeline(timeline: newEvent)
                    }
                    currentRoom = room
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
            //.whereField("ownerID", isEqualTo: pid)
            .whereField("playersIDs", arrayContainsAny: [pid])
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
        
        disposeRoomListener()
        
        roomListener = roomCollection.document(id).addSnapshotListener{ documentSnapshot,error in
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
    
    private func listenToRoomTimelineDataChange(id: String) {
        guard !id.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        disposeTimelineListener()
        
        timelineListener = timelineCollection
            .whereField("roomID", isEqualTo: id)
            .order(by: "datetime", descending: false)
            .addSnapshotListener {snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                } else {
                    do {
                        let fullTimeline: [RoomTimeline] = try snapshot?.documents.compactMap {
                            try $0.data(as: RoomTimeline.self)
                        } ?? []
                        
                        //Add all timeline to the currentTimeLine
                        if self.currentTimeline.count == 0 {
                            self.currentTimeline = fullTimeline
                        }
                        
                        if fullTimeline.count > 0 {
                            let event = fullTimeline.last!
                            
                            if !self.currentTimeline.contains(where: { $0.id == event.id}) {
                                self.currentTimeline.append(event)
                            }
                            
                            NotificationCenter.default.post(name: .roomTimelineAdded, object:event)
                        }
                    } catch {
                        print("Error decoding documents: \(error.localizedDescription)")
                    }
                }
            }
    }
    
    private func disposeRoomListener() {
        if roomListener != nil {
            roomListener?.remove()
            roomListener = nil
        }
    }
    
    private func disposeTimelineListener() {
        if timelineListener != nil {
            timelineListener?.remove()
            timelineListener = nil
        }
    }
    
    private func addEventToRoomTimeline(timeline: RoomTimeline) async throws -> Void {
        
        do {
            try await timelineCollection.document(timeline.id).setData(timeline.asDictionary())
        }
        catch {
            print(error)
        }
    }
}
