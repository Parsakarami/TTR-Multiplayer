//
//  RegisterViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import Foundation

class RegisterViewModel : ObservableObject {
    @Published var fullName : String = ""
    @Published var email : String = ""
    @Published var password : String = ""
    @Published var errorMessage : String = ""
    
    func register()
    {
        if validate() {
            
        }
    }
    
    func validate() -> Bool {
        if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Full name cannot be empty"
            return false
        }
        
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Email cannot be empty"
            return false
        }
        
        if password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Password cannot be empty"
            return false
        }
        
        return true
    }
}
