//
//  LoginViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import Foundation

class LoginViewModel : ObservableObject {
    @Published var email : String = ""
    @Published var password : String = ""
    
    init() {}
    
    func login(){
        
    }
    
    func validate() -> Bool {
        
        
        
        return false
    }
}
