//
//  RegisterViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class RegisterViewModel : ObservableObject {
    @Published var fullName : String = ""
    @Published var email : String = ""
    @Published var password : String = ""
    @Published var message : String = ""
    @Published var isSuccessful : Bool = false
    @Published var dismissTheRegisterSheet : Bool = false
    @Published var selectedImage : UIImage? = nil
    private let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$"#
    
    func register()
    {
        guard validate() else {
            return
        }
        
        var imageData : Data? = nil
        if let image = selectedImage {
            imageData = image.pngData()
        }
        
        PlayerService.instance.signUp(fullName: fullName, email: email, password: password, profilePhoto: imageData) { [weak self] result in
            do {
                let value = try result.get()
                if value {
                    self?.isSuccessful = true
                    self?.message = "Welcome \(self?.fullName ?? "")"
                }
            } catch {
                self?.message = error.localizedDescription
            }
        }
    }
    
    func validate() -> Bool {
        if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            message = "Full name cannot be empty"
            return false
        }
        
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            message = "Email cannot be empty"
            return false
        }
        
        if password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            message = "Password cannot be empty"
            return false
        }
        
        let isValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        if !isValid {
            message = "Email address is not valid"
            return false
        }
        
        return true
    }
}
