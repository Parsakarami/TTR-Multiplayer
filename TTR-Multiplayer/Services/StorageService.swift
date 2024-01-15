//
//  StorageService.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-06.
//

import Foundation
import FirebaseStorage

class StorageService {
    static var instance = StorageService()
    private var storageReference : StorageReference
    public private(set) var playerImageCache : [String:Data] = [:]
    init() {
        let storage = Storage.storage().reference()
        self.storageReference = storage.child("images/")
    }
    
    func initialize() {
        
    }
    
    func getProfilePhotoURL(uid: String) async throws -> String {
        guard !uid.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw NSError(domain: "TicketToRide.StorageService.GetProfilePhotoURL", code: 0, userInfo: [NSLocalizedDescriptionKey:"Input id is invalid"])
        }
        
        let photoName = "\(uid).png"
        let profileStorageReference = storageReference.child("/profiles/\(photoName)")
        
        //Use default if file is not available
        do {
            let result = try await profileStorageReference.downloadURL()
            downloadProfilePhotoData(playerId: uid, from: result.absoluteURL)
            return result.absoluteString
        } catch {
            let result = try await storageReference.child("/profiles/user.png").downloadURL()
            downloadProfilePhotoData(playerId: uid, from: result.absoluteURL)
            return result.absoluteString
        }
    }
    
    func uploadProfilePhoto(uid: String, data: Data, completion: @escaping (Result<URL?, Error>) -> Void) {
        let photoName = "\(uid).png"
        let profileStorageReference = storageReference.child("/profiles/\(photoName)")
        
        profileStorageReference.putData(data){ _,error in
            guard error == nil else {
                let nsError = NSError(domain: "TicketToRide.StorageService.UploadPlayerProfilePhoto", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot upload player photo to the database."])
                completion(.failure(nsError))
                return
            }
            
            profileStorageReference.downloadURL{ result, downloadError in
                guard let result = result, downloadError == nil else {
                    let error = NSError(domain: "TicketToRide.StorageService.UploadPlayerProfilePhoto", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot download back the player photo from the database."])
                    completion(.failure(error))
                    return
                }
                
                completion(.success(result))
            }
        }
    }
    
    func downloadProfilePhotoData(playerId pid: String, from url: URL) {
            URLSession.shared.dataTask(with: url) { (data, _, error) in
                if let error = error {
                    print("Error downloading data: \(error.localizedDescription)")
                    return
                }

                if let data = data {
                    DispatchQueue.main.async {
                        self.playerImageCache[pid] = data
                    }
                }
            }.resume()
        }
}
