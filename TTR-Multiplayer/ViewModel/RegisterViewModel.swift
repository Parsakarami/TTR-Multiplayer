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
    private let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$"#
    
    func register()
    {
        guard validate() else {
            return
        }
        
        PlayerService.instance.signUp(fullName: fullName, email: email, password: password) { [weak self] result in
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
