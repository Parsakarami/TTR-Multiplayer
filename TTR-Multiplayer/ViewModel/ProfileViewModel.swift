//
//  ProfileViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-05.
//

import Foundation
import UIKit

class ProfileViewModel : ObservableObject {
    @Published var player : Player? = nil
    @Published var profilePhoto : String = ""
    @Published var message : String = ""
    @Published var isSuccessful : Bool = false
    @Published var selectedImage : UIImage? = nil
    
    init() {
        guard let currentPlayer = PlayerService.instance.player else {
            return
        }
        
        self.player = currentPlayer
        self.profilePhoto = PlayerService.instance.playerProfilePhoto
    }
    
    func updateProfile() {
        guard let player = player else {
            message = "Failed to update profile"
            return
        }
        
        guard let selectedImage = selectedImage else {
            message = "Photo not selected!"
            return
        }
        
        guard let data = selectedImage.pngData() else {
            message = "Photo is invalid."
            return
        }
        
        PlayerService.instance.uploadPlayerProfilePhoto(userid: player.id, photoData: data) { [weak self] result in
            switch result {
            case .success(_):
                self?.isSuccessful = true
                self?.message = "Successful"
                
                break
            case .failure(_):
                break
            }
        }
    }
    
    func uploadProfile() {
        
    }
}
