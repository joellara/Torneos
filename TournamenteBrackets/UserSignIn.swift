//
//  UserSignIn.swift
//  Tourney
//
//  Created by Joel Lara Quintana on 28/04/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import Foundation
import Gloss
struct UserSignIn:Decodable{
    var loggedIn = false
    var valid = false
    let api_key:String?
    let email:String?
    let name:String?
    let message:String?
    
    init?(json: JSON) {
        guard let loggedIn: Bool = "loggedIn" <~~ json else {
            return nil
        }
        guard let valid: Bool = "valid" <~~ json else {
            return nil
        }
        self.loggedIn = loggedIn
        self.valid = valid
        self.api_key = "api_key" <~~ json
        self.email = "email" <~~ json
        self.name = "name" <~~ json
        self.message = "message" <~~ json
    }
}
