//
//  RegisterViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class RegisterViewModel : ObservableObject {
    @Published var fullName : String = ""
    @Published var email : String = ""
    @Published var password : String = ""
    @Published var errorMessage : String = ""
    @Published var dismissTheRegisterSheet : Bool = false
    private let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$"#
    
    func register()
    {
        guard validate() else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let userId = result?.user.uid else {
                return
            }
            
            self?.insertUserIntoDatabase(id: userId)
        }
    }
    
    func insertUserIntoDatabase(id: String){
        let newPlayer = Player(id: id,
                            fullName: fullName,
                            email: email,
                            joinedDate: Date().timeIntervalSince1970)
        
        let db = Firestore.firestore()
        db.collection("players")
            .document(id)
            .setData(newPlayer.asDictionary())
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
        
        
        let isValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        if !isValid {
            errorMessage = "Email address is not valid"
            return false
        }
        
        return true
    }
}
