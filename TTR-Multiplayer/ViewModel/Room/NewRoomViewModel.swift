//
//  NewRoomViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-03.
//

import Foundation

class NewRoomViewModel : ObservableObject {
    @Published var roomCode : String = ""
    @Published var roomCapacity : Double = 1
    @Published var roomCreator : String = ""
    
    @Published var errorMessage : String = ""
    func addRoom() {
        
    }
    
    func validate() -> Bool {
        
//        //Validate code
//        if true == false {
//            errorMessage = "The code is already in used!"
//            return false
//        }
        
        
        if roomCapacity < 1 && roomCapacity > 5 {
            errorMessage = "Room capacity is invalid!"
            return false
        }
        
        return true
    }
}
