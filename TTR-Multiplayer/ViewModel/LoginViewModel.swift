//
//  LoginViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import Foundation
import FirebaseAuth

class LoginViewModel : ObservableObject {
    @Published var email : String = ""
    @Published var password : String = ""
    @Published var errorMessage : String = ""
    @Published var isAuthorized : Bool = false
    private let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$"#
    func login()
    {
        guard validate() else {
            return
        }
        
        PlayerService.instance.signIn(email: email, password: password) { [weak self] result in
            do {
                let value = try result.get()
                self?.isAuthorized = value
            } catch {
                self?.errorMessage = error.localizedDescription
                self?.isAuthorized = false
            }
        }
        
    }
    
    func validate() -> Bool {
        
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Email cannot be empty"
            return false
        }
        
        if password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Password cannot be empty"
            return false
        }
        
        let isValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        if !isValid {
            errorMessage = "Email address is not valid"
            return false
        }
        
        return true
    }
}
