//
//  NewRoomViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-03.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class NewRoomViewModel : ObservableObject {
    @Published var roomCode : String = ""
    @Published var roomCapacity : Double = 1
    @Published var roomCreator : String = ""
    @Published var errorMessage : String = ""
    @Published var isSuccessful : Bool = false
    @Published var isAdding : Bool = false
    private var roomCollection : CollectionReference
    private var userID : String
    init() {
        let db = Firestore.firestore()
        roomCollection = db.collection("rooms")
        userID = Auth.auth().currentUser?.uid ?? ""
    }
    
    func addNewRoom() async {
        guard isAdding == false else {
            return
        }
        
        guard validate() else {
            return
        }
        
        guard let player = PlayerService.instance.player else {
            return
        }
        
        isAdding = true
        let newRoom = Room(id: UUID().uuidString,
                           ownerID: userID,
                           roomCode: roomCode,
                           capacity : Int(roomCapacity),
                           inUsed: true,
                           winner: nil,
                           createdDateTime: Date().timeIntervalSince1970,
                           playersIDs: [userID],
                           playersPoints: [PlayerPoint(playerId: userID)])
        
        do {
            let result = try await RoomService.instance.addRoom(room: newRoom , player: player)
            isSuccessful = result
        }catch {
            errorMessage = error.localizedDescription
        }
        isAdding = false
    }
    
    private func validate() -> Bool {
        //Check athentication
        guard userID != "" else {
            errorMessage = "You are not signed in!"
            return false
        }
        
        //Check room code
        guard !roomCode.isEmpty else {
            errorMessage = "Room access code is empty!"
            return false
        }
        
        //Check capacity
        if roomCapacity < 1 && roomCapacity > 5 {
            errorMessage = "Room capacity is invalid!"
            return false
        }
            
        return true
    }
}
