//
//  PlayerService.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-04.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class PlayerService {
    static var instance = PlayerService()
    private var playerCollection : CollectionReference
    private var storageReference : StorageReference
    private var currentUser : User?
    private var handler : AuthStateDidChangeListenerHandle?
    public private(set) var player : Player?
    public private(set) var playerProfile : String = ""
    
    init() {
        let storage = Storage.storage().reference()
        let db = Firestore.firestore()
        playerCollection = db.collection("players")
        currentUser = Auth.auth().currentUser
        self.storageReference = storage.child("images/profiles/")
        
        self.handler = Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            DispatchQueue.main.async {
                let uid = user?.uid ?? ""
                if !uid.trimmingCharacters(in: .whitespaces).isEmpty {
                    self?.fetchPlayer(id: uid) { result in
                        do {
                            self?.player = try result.get()
                            self?.currentUser = user
                            
                            let imageName = "\(self?.player?.id ?? "user").png"
                            
                            //download the user profile
                            self?.storageReference.child(imageName).downloadURL{ url, error in
                                // if couldn't, download the default file
                                guard let url = url, error == nil else {
                                    self?.storageReference.child("user.png").downloadURL{ defaultUrl, error in
                                        guard let defaultUrl = defaultUrl, error == nil else {
                                            self?.sendNotification(status: .authorized)
                                            return
                                        }
                                        self?.playerProfile = defaultUrl.absoluteString
                                        self?.sendNotification(status: .authorized)
                                    }
                                    return
                                }
                                self?.playerProfile = url.absoluteString
                                self?.sendNotification(status: .authorized)
                            }
                        } catch {
                            self?.player = nil
                            self?.currentUser = nil
                            self?.sendNotification(status: .notAuthorized)
                            print(error)
                        }
                    }
                }
            }
        }
    }
    
    func initialize() {
        
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
            
            self.insertPlayer(id: id, fullName: fullName, email: email)
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
    
    private func insertPlayer(id: String, fullName: String, email: String){
        let newPlayer = Player(id: id,
                            fullName: fullName,
                            email: email,
                            joinedDate: Date().timeIntervalSince1970)
        
        let db = Firestore.firestore()
        db.collection("players")
            .document(id)
            .setData(newPlayer.asDictionary())
    }
    
    private func updatePlayer(player: Player){
        
    }
    
    private func sendNotification(status: authStatus) {
        NotificationCenter.default.post(name: .playerAuthStatusChanged, object: status)
    }
    
}
