//
//  PlayerService.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-04.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserService {
    static var instance = UserService()
    private var playerCollection : CollectionReference
    private var currentUser : User?
    private var handler : AuthStateDidChangeListenerHandle?
    
    init() {
        let db = Firestore.firestore()
        playerCollection = db.collection("players")
        currentUser = Auth.auth().currentUser
        self.handler = Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            self?.currentUser = user
        }
    }
    
    public var isSignedIn : Bool {
        return currentUser != nil
    }
    
    public var userId : String {
        return currentUser?.uid ?? ""
    }
    
    public func joinRoom(roomCode: String) {
        
    }
}
