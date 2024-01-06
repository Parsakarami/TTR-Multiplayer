//
//  ProfileViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-05.
//

import Foundation

class ProfileViewModel : ObservableObject {
    @Published var player : Player? = nil
    @Published var profilePhoto : String = ""
    init() {
        guard let currentPlayer = PlayerService.instance.player else {
            return
        }
        
        self.player = currentPlayer
        self.profilePhoto = PlayerService.instance.playerProfilePhoto
    }
    
    func updateProfile() {
        
    }
    
    func uploadProfile() {
        
    }
}
