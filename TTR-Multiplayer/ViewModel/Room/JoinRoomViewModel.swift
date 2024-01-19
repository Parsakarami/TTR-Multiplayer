//
//  JoinRoomViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-04.
//

import Foundation

class JoinRoomViewModel : ObservableObject {
    @Published var roomAccessCode : String = ""
    @Published var message : String = ""
    @Published var isSuccessful : Bool = false
    @Published var isJoining : Bool = false
    init() {
        
    }
    
    func joinRoom() async throws -> Void{
        guard canJoin() else {
            return
        }
        
        isJoining = true
            isSuccessful = try await RoomService.instance.joinRoom(roomCode: roomAccessCode)
            if isSuccessful {
                message = "Successful"
            } else {
                message = "Cannot join to the room."
            }
            isJoining = false
    }
    
    func canJoin() -> Bool {
        guard !roomAccessCode.trimmingCharacters(in: .whitespaces).isEmpty else {
            message = "Access code cannot be empty."
            return false
        }
        
        return true
    }
}
