//
//  MainViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MainViewModel : ObservableObject {
    @Published var currentUserId : String = ""
    @Published var player : Player? = nil
    @Published var isAuthorized : Bool = false
    private var handler: AuthStateDidChangeListenerHandle?
    
    init(){
        self.handler = Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            DispatchQueue.main.async {
                let uid = user?.uid ?? ""
                self?.currentUserId = uid
                let hasId = !uid.trimmingCharacters(in: .whitespaces).isEmpty
                
                if hasId {
                    self?.fetchPlayer(id: uid)
                }
                self?.isAuthorized = hasId
            }
        }
    }
    
    private func fetchPlayer(id:String) {
        let db = Firestore.firestore()
        db.collection("players")
            .document(id)
            .getDocument {(querySnapshot, error) in
                if let error = error {
                    print("Error getting document: \(error)")
                } else {
                    do {
                        self.player = try querySnapshot?.data(as: Player.self)
                    } catch {
                        print("Cannot fetch date from database")
                    }
                }
            }
    }
    
    public var isSignedIn : Bool {
        return Auth.auth().currentUser != nil
    }
}
