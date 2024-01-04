//
//  PlayerService.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-04.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class PlayerService {
    static var instance = PlayerService()
    private var playerCollection : CollectionReference
    private var currentUser : User?
    private var handler : AuthStateDidChangeListenerHandle?
    var player : Player?
    
    init() {
        let db = Firestore.firestore()
        playerCollection = db.collection("players")
        currentUser = Auth.auth().currentUser
        self.handler = Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                let uid = user?.uid ?? ""
                if !uid.trimmingCharacters(in: .whitespaces).isEmpty {
                    self?.fetchPlayer(id: uid)
                }
            }
        }
    }
    
    public func signIn(email: String, password: String) -> Bool {
        Auth.auth().signIn(withEmail: email, password: password)
        return true
    }
    
    public func signOut(){
        if isSignedIn {
            try? Auth.auth().signOut()
            NotificationCenter.default.post(name: .playerAuthStatusChanged, object: authStatus.notAuthorized)
            player = nil
        }
    }
    
    public var isSignedIn : Bool {
        return currentUser != nil
    }
    
    public func joinRoom(roomCode: String) {
        
    }
    
    private func fetchPlayer(id:String) {
        let db = Firestore.firestore()
        db.collection("players")
            .document(id)
            .getDocument { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting document: \(error)")
                } else {
                    do {
                        self?.player = try querySnapshot?.data(as: Player.self)
                        NotificationCenter.default.post(name: .playerAuthStatusChanged, object: authStatus.authorized)
                    } catch {
                        print("Cannot fetch date from database")
                    }
                }
            }
    }
    
}
