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
    @Published var message : String = ""
    @Published var isSuccessful : Bool = false
    @Published var isUpdating : Bool = false
    @Published var selectedImage : UIImage? = nil
    
    init() {
        guard let currentPlayer = PlayerService.instance.player else {
            return
        }
        
        self.player = currentPlayer
        
        let profileURL = PlayerService.instance.playerProfilePhoto
        guard !profileURL.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        reloadProfilePhoto(url: profileURL)
    }
    
    func updateProfile() {
        isUpdating = true
        guard let player = player else {
            message = "Failed to update profile"
            isUpdating = false
            return
        }
        
        guard let selectedImage = selectedImage else {
            message = "Photo not selected!"
            isUpdating = false
            return
        }
        
        guard let data = selectedImage.pngData() else {
            message = "Photo is invalid."
            isUpdating = false
            return
        }
        
        PlayerService.instance.uploadPlayerProfilePhoto(userid: player.id, photoData: data) { [weak self] result in
            switch result {
            case .success(_):
                self?.isSuccessful = true
                self?.message = "Successful"
                self?.reloadProfilePhoto(url: PlayerService.instance.playerProfilePhoto)
                self?.isUpdating = false
                break
            case .failure(_):
                break
            }
        }
    }
    
    private func loadImageFromURL(url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    private func reloadProfilePhoto(url: String) {
        guard !url.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        guard let photoURL = URL(string: url) else {
            return
        }
        
        self.loadImageFromURL(url: photoURL) { [weak self] result in
            guard let image = result else {
                return
            }
            self?.selectedImage = image
        }
    }
}
