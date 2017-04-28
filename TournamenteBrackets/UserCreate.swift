//
//  User.swift
//  Tourney
//
//  Created by Joel Lara Quintana on 28/04/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import Gloss
import Foundation

struct UserCreate:Decodable{
    let created:Bool?
    let valid:Bool?
    let api_key:String?
    let email:String?
    let name:String?
    
    init?(json: JSON) {
        guard let created: Bool = "created" <~~ json else {
            return nil
        }
        guard let valid: Bool = "valid" <~~ json else {
            return nil
        }
        self.created = created
        self.valid = valid
        self.api_key = "api_key" <~~ json
        self.email = "email" <~~ json
        self.name = "name" <~~ json
        
    }
}
