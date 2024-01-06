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
    public private(set) var playerProfilePhoto : String = ""
    
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
                                            self?.sendNotification(status: playerStatus.authorized )
                                            return
                                        }
                                        self?.playerProfilePhoto = defaultUrl.absoluteString
                                        self?.sendNotification(status: .authorized)
                                    }
                                    return
                                }
                                self?.playerProfilePhoto = url.absoluteString
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
    
    public func signUp(fullName: String, email: String, password: String, profilePhoto: Data?, completion: @escaping (Result<Bool,Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let id = result?.user.uid else {
                let error = NSError(domain: "TicketToRide.SignUp", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to sign up."])
                completion(.failure(error))
                return
            }
            
            self?.insertPlayer(id: id, fullName: fullName, email: email, profilePhoto: profilePhoto) { insertResult in
                switch insertResult {
                case .success(_):
                    completion(.success(true))
                    self?.sendNotification(status: playerStatus.authorized)
                    return
                case .failure(let insertError):
                    completion(.failure(insertError))
                    return
                }
            }
        }
    }
    
    public func signOut(){
        if isSignedIn {
            try? Auth.auth().signOut()
            NotificationCenter.default.post(name: .playerAuthStatusChanged, object: playerStatus.notAuthorized)
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
    
    private func insertPlayer(id: String, fullName: String, email: String, profilePhoto: Data?, completion: @escaping (Result<Bool,Error>) -> Void) {
        let newPlayer = Player(id: id,
                               fullName: fullName,
                               email: email,
                               joinedDate: Date().timeIntervalSince1970)
        
        let db = Firestore.firestore()
        db.collection("players")
            .document(id)
            .setData(newPlayer.asDictionary()) { [weak self] error in
                
                guard error == nil else {
                    let error = NSError(domain: "TicketToRide.InsertPlayer", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot insert player data to the database."])
                    completion(.failure(error))
                    return
                }
                
                guard let data = profilePhoto else {
                    completion(.success(true))
                    return
                }
                
                //Successfully added
                //Try uploding user photo
                self?.uploadPlayerProfilePhoto(userid: id, photoData: data) { r in
                    switch r {
                    case .success(_):
                        completion(.success(true))
                        self?.sendNotification(status: playerStatus.profileUpdated)
                        return
                    case .failure(let taskError):
                        completion(.failure(taskError))
                        return
                    }
                }
            }
    }
    
    public func uploadPlayerProfilePhoto(userid: String, photoData: Data, completion: @escaping (Result<Bool, Error>) -> Void) {
        StorageService.instance.uploadProfilePhoto(uid: userid, data: photoData) { [weak self] result in
            switch result {
            case .success(let url):
                guard let photoAddress = url else {
                    completion(.success(false))
                    return
                }
                self?.playerProfilePhoto = photoAddress.absoluteString
                self?.sendNotification(status: .profileUpdated)
                completion(.success(true))
                break
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
    
    private func sendNotification(status: playerStatus) {
        NotificationCenter.default.post(name: .playerAuthStatusChanged, object: status)
    }
    
}
