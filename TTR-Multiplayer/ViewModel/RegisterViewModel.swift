//
//  RegisterViewModel.swift
//  TTR-Multiplayer
//
//  Created by Parsa Karami on 2024-01-02.
//

import Foundation

class RegisterViewModel : ObservableObject {
    @Published var username : String = ""
    @Published var email : String = ""
    @Published var password : String = ""
}
