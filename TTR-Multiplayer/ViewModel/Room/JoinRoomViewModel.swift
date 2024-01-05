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
    init() {
        
    }
    
    func joinRoom(){
        guard canJoin() else {
            return
        }
    }
    
    func canJoin() -> Bool {
        message = "Access code is incorrect."
        return false
    }
}
