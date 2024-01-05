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
                let uid = user?.uid ?? ""
                if !uid.trimmingCharacters(in: .whitespaces).isEmpty {
                    self?.fetchPlayer(id: uid) { result in
                        do {
                            self?.player = try result.get()
                            self?.currentUser = user
                            NotificationCenter.default.post(name: .playerAuthStatusChanged, object: authStatus.authorized)
                        } catch {
                            self?.player = nil
                            self?.currentUser = nil
                            NotificationCenter.default.post(name: .playerAuthStatusChanged, object: authStatus.notAuthorized)
                            print(error)
                        }
                    }
                }
            }
        }
    }
    
    public var isSignedIn : Bool {
        return currentUser != nil
    }
    
    public func signIn(email: String, password: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            guard error == nil else {
                return completion(.failure(error!))
            }
            
            guard result != nil else {
                return completion(.failure(error!))
            }
            
            guard (result?.user.uid) != nil else {
                let error = NSError(domain: "TicketToRide.SignIn", code: 0, userInfo: [NSLocalizedDescriptionKey: "Email or password is incorrect."])
                return completion(.failure(error))
            }
            
            completion(.success(true))
        }
    }
    
    public func signUp(fullName: String, email: String, password: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard error == nil else {
                return completion(.failure(error!))
            }
            
            guard let id = result?.user.uid else {
                let error = NSError(domain: "TicketToRide.SignUp", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to sign up."])
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
    
    public func joinRoom(roomCode: String) {
        
    }
    
    private func fetchPlayer(id:String, completion: @escaping (Result<Player,Error>) -> Void) {
        playerCollection.document(id).getDocument { (querySnapshot, error) in
                guard error == nil else {
                    return completion(.failure(error!))
                }
            
                do {
                    let player = try querySnapshot?.data(as: Player.self)
                    completion(.success(player!))
                } catch {
                    let error = NSError(domain: "TicketToRide.FetchPlayer", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot fetch data from database."])
                    completion(.failure(error))
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
