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
    private var ticketCollection : CollectionReference
    public private(set) var currentRoom : Room?
    public private(set) var currentTimeline : [RoomTimeline] = []
    private var roomListener : ListenerRegistration? = nil
    private var timelineListener : ListenerRegistration? = nil
    private var allTickets : [Destination] = []
    public private(set) var playerCurrentTickets : [GameDestinationCard] = []
    
    init() {
        let db = Firestore.firestore()
        roomCollection = db.collection("rooms")
        timelineCollection = db.collection("timelines")
        ticketCollection = db.collection("tickets")
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
                    try await populateTickets()
                    let result = try await fetchActiveRoom(pid: pid)
                    guard let room = result else {
                        return
                    }
                    self.currentRoom = room
                    
                    //fetch tickets
                    playerCurrentTickets = try await getPlayerDestinationCards(roomId: room.id, playerId: pid)
                    
                    self.listenToRoomDataChange(id:room.id)
                    self.listenToRoomTimelineDataChange(id: room.id)
                    NotificationCenter.default.post(name: .roomStatusChanged, object: roomStatus.fetchedCurrentRoom)
                }
            }
        }
    }
    
    func initialize() {
        
    }
    
    //Room Actions
    public func addRoom(room: Room, player: Player) async throws -> Bool {
        let isInUsed = try await RoomService.instance.isRoomInUsed(code: room.roomCode)
        if !isInUsed {
            do {
                try await roomCollection.document(room.id)
                    .setData(room.asDictionary())
                
                // fill all of the destination card to the collection
                for ticket in allTickets {
                    try await roomCollection.document(room.id)
                        .collection("tickets").document(ticket.id).setData(ticket.asDictionary())
                }
                
                currentRoom = room
                listenToRoomDataChange(id:room.id)
                listenToRoomTimelineDataChange(id: room.id)
                
                let newEvent = RoomTimeline(id: UUID().uuidString,
                                            roomID: room.id,
                                            creatorID: player.id,
                                            datetime: Date().timeIntervalSince1970,
                                            eventType: roomTimelineEventType.started.rawValue,
                                            description: "The game has started.")
                try await addEventToRoomTimelineAsync(timeline: newEvent)
                
                NotificationCenter.default.post(name: .roomStatusChanged, object: roomStatus.created)
                return true
            } catch {
                return false
            }
        } else {
            return false
        }
    }
    
    public func closeRoom(id: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        roomCollection.document(id).updateData([
            "inUsed" : false
        ]) { [weak self] error in
            if let error = error {
                completion(.failure(error))
            }
            self?.disposeRoomListener()
            self?.disposeTimelineListener()
            
            
            guard let player = PlayerService.instance.player else {
                completion(.success(true))
                return
            }
            
            let newEvent = RoomTimeline(id: UUID().uuidString,
                                        roomID: id,
                                        creatorID: player.id,
                                        datetime: Date().timeIntervalSince1970,
                                        eventType: roomTimelineEventType.closed.rawValue,
                                        description: "\(player.fullName) closed the room.")
            
            self?.addEventToRoomTimeline(timeline: newEvent)
            
            NotificationCenter.default.post(name: .roomStatusChanged, object: roomStatus.closed)
            completion(.success(true))
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
            self?.disposeRoomListener()
            self?.disposeTimelineListener()
            NotificationCenter.default.post(name: .roomStatusChanged, object: roomStatus.quited)
        }
        
        Task {
            let newEvent = RoomTimeline(id: UUID().uuidString,
                                        roomID: room.id,
                                        creatorID: player.id,
                                        datetime: Date().timeIntervalSince1970,
                                        eventType: roomTimelineEventType.playerQuit.rawValue,
                                        description: "\(player.fullName) left the game.")
            
            try await self.addEventToRoomTimelineAsync(timeline: newEvent)
        }
    }
    
    public func joinRoom(roomCode: String) async throws -> Bool {
        guard roomCode.trimmingCharacters(in: .whitespaces) != "" else {
            return false
        }
        
        let snapShot = try await roomCollection
            .whereField("roomCode", isEqualTo: roomCode)
            .whereField("inUsed", isEqualTo: true)
            .getDocuments()
        
        if !snapShot.isEmpty{
            for doc in snapShot.documents {
                let room = try doc.data(as: Room.self)
                guard let player = PlayerService.instance.player else {
                    break
                }
                
                let canJoin = room.ownerID != player.id && room.capacity > 0
                if canJoin {
                    
                    let fullTimeline = try await fetchFullTimeline(roomId: room.id)
                    for event in fullTimeline {
                        NotificationCenter.default.post(name: .roomTimelineAdded, object:event)
                    }
                    
                    listenToRoomDataChange(id:room.id)
                    
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
                        
                        try await addEventToRoomTimelineAsync(timeline: newEvent)
                    }
                    currentRoom = room
                    listenToRoomTimelineDataChange(id: room.id)
                    return true
                }
                break
            }
        }
        return false
    }
    
    //Card Actions
    public func pickThreeTickets(pid: String) async throws -> [GameDestinationCard] {
        // fetch latest ticket from the room
        var threeTickets : [GameDestinationCard] = []
        guard let room = currentRoom else {
            return threeTickets
        }
        
        
        // Send notification
        let player = PlayerService.instance.playersCache[pid]!.player
        let newEvent = RoomTimeline(id: UUID().uuidString,
                                    roomID: room.id,
                                    creatorID: pid,
                                    datetime: Date().timeIntervalSince1970,
                                    eventType: roomTimelineEventType.playerRequestedTickets.rawValue,
                                    description: "\(player.fullName) requested destination cards.")
        try await addEventToRoomTimelineAsync(timeline: newEvent)
        
        
        let tickets = try await getLatestDestinationCards(roomId: room.id)
        //reset discarded tickets if there is no more available in the deck
        
        
        // choose three cards which are not selected yet
        threeTickets = Array(tickets
            .filter({$0.isSelected == nil && $0.userID == nil})
            .shuffled()
            .prefix(3))
        
        // update taken tickets with userid
        for ticket in threeTickets {
            try await updateDestinationCards(roomId: room.id, ticketId: ticket.id, pid: pid)
        }
        
        // return to the tickets
        return threeTickets
    }
    
    public func pickTickets(roomID: String, tickets: [GameDestinationCard]) async throws -> Bool {
        guard !roomID.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        
        var pid = ""
        var selectionNumber = 0
        // update tickets
        for ticket in tickets.filter({ $0.isSelected == true}) {
            
            try await updateDestinationCards(roomId: roomID,
                                             ticketId: ticket.id,
                                             pid: ticket.userID!,
                                             isSelcted: ticket.isSelected!)
            
            //update current cards
            guard let isSelected = ticket.isSelected else{
                continue
            }
            
            if isSelected {
                playerCurrentTickets.append(ticket)
                selectionNumber += 1
            }
            
            pid = ticket.userID!
        }
        
        // Send notification
        guard let playerModel = PlayerService.instance.playersCache[pid] else {
            return true
        }
        
        let player = playerModel.player
        let eventDescription = "\(player.fullName) picked \(selectionNumber) destination card\(selectionNumber == 1 ? "." : "s.")"
        let newEvent = RoomTimeline(id: UUID().uuidString,
                                    roomID: roomID,
                                    creatorID: player.id,
                                    datetime: Date().timeIntervalSince1970,
                                    eventType: roomTimelineEventType.playerPickedTickets.rawValue,
                                    description: eventDescription)
        try await addEventToRoomTimelineAsync(timeline: newEvent)
        
        return true
    }
    
    //Private memebers
    private func isRoomInUsed(code: String) async throws -> Bool {
        let snapShots = try await roomCollection
            .whereField("roomCode", isEqualTo: code)
            .whereField("inUsed", isEqualTo: true)
            .getDocuments()
        
        return !snapShots.isEmpty
    }
    
    private func populateTickets() async throws -> Void {
        guard allTickets.count == 0 else {
            return
        }
        
        let snapShot = try await ticketCollection.getDocuments()
        
        guard !snapShot.isEmpty else {
            return
        }
        
        self.allTickets = try snapShot.documents.map { doc in
            try doc.data(as: Destination.self)
        }
        
        return
    }
    
    private func addEventToRoomTimelineAsync(timeline: RoomTimeline) async throws -> Void {
        
        do {
            try await timelineCollection.document(timeline.id).setData(timeline.asDictionary())
        }
        catch {
            print(error)
        }
    }
    
    private func addEventToRoomTimeline(timeline: RoomTimeline) {
        timelineCollection.document(timeline.id).setData(timeline.asDictionary())
    }
    
    private func fetchFullTimeline(roomId: String) async throws -> [RoomTimeline] {
        var fullTimeline : [RoomTimeline] = []
        guard !roomId.trimmingCharacters(in: .whitespaces).isEmpty else {
            return fullTimeline
        }
        
        do {
            let snapShot = try await timelineCollection
                .whereField("roomID", isEqualTo: roomId)
                .order(by: "datetime", descending: false)
                .getDocuments()
            
            guard !snapShot.isEmpty else {
                return fullTimeline
            }
            
            fullTimeline = try snapShot.documents.map { doc in
                try doc.data(as: RoomTimeline.self)
            }
            
        } catch {
            print(error)
        }
        return fullTimeline
    }
    
    private func fetchActiveRoom(pid: String) async throws -> Room? {
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
                
                let fullTimeline = try await fetchFullTimeline(roomId: room!.id)
                for event in fullTimeline {
                    NotificationCenter.default.post(name: .roomTimelineAdded, object:event)
                }
                
                break
            }
        }
        
        return room
    }
    
    private func fetchRooms(pid: String) async throws -> [Room] {
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
    
    private func getLatestDestinationCards(roomId: String) async throws -> [GameDestinationCard] {
        var gameDestinations : [GameDestinationCard] = []
        guard roomId.trimmingCharacters(in: .whitespaces) != "" else {
            return gameDestinations
        }
        
        let snapShot = try await roomCollection.document(roomId).collection("tickets").getDocuments()
        if !snapShot.isEmpty{
            for doc in snapShot.documents {
                let ticket = try doc.data(as: GameDestinationCard.self)
                gameDestinations.append(ticket)
            }
        }
        
        return gameDestinations
    }
    
    private func updateDestinationCards(roomId: String, ticketId: String, pid: String? = nil, isSelcted: Bool? = nil) async throws -> Void {
        try await roomCollection
            .document(roomId)
            .collection("tickets")
            .document(ticketId)
            .updateData([
                "isSelected" : isSelcted as Any,
                "userID" : pid as Any
            ])
    }
    
    private func getPlayerDestinationCards(roomId: String, playerId : String) async throws -> [GameDestinationCard] {
        var playerCards : [GameDestinationCard] = []
    
        guard roomId.trimmingCharacters(in: .whitespaces) != "" else {
            return playerCards
        }
        
        let snapShot = try await roomCollection
            .document(roomId)
            .collection("tickets")
            .whereField("userID", isEqualTo: playerId)
            .whereField("isSelected", isEqualTo: true)
            .getDocuments()
            
        if !snapShot.isEmpty{
            for doc in snapShot.documents {
                let ticket = try doc.data(as: GameDestinationCard.self)
                playerCards.append(ticket)
            }
        }
        
        return playerCards
    }
    
    //Listeners
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
}
