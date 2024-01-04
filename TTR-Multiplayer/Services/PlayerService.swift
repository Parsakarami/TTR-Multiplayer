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
    
    public func signUp(fullName: String, email: String, password: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let id = result?.user.uid else {
                let error = NSError(domain: "TicketToRide", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create user."])
                return completion(.failure(error))
            }
            
            self.insertPlayerIntoDatabase(id: id, fullName: fullName, email: email)
            completion(.success(true))
        }
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
    
    private func insertPlayerIntoDatabase(id: String, fullName: String, email: String){
        let newPlayer = Player(id: id,
                            fullName: fullName,
                            email: email,
                            joinedDate: Date().timeIntervalSince1970)
        
        let db = Firestore.firestore()
        db.collection("players")
            .document(id)
            .setData(newPlayer.asDictionary())
    }
    
}
