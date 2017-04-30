//
//  Tournament.swift
//  MyBrackets
//
//  Created by Joel Lara Quintana on 20/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import Foundation
import Gloss

struct Tournament : Decodable, Glossy {
    
    var format:Tournament.tournament_format
    var participants = [String]()
    
    
    enum tournament_format:String  {
        case singleElimination = "single_elimination"
        case doubleElimination = "double_elimination"
        case roundRobin = "round_robin"

        static func decodeTournamentFormat(key: String, json: JSON) -> Tournament.tournament_format? {
            
            guard let tournament_format: String = key <~~ json else {
                return nil
            }
            if let type = Tournament.tournament_format(rawValue: tournament_format) {
                return type
            }
            return nil
        }
    }
    
    init?(json: JSON) {
        guard let tournament_format = tournament_format.decodeTournamentFormat(key: "tournament_type", json: json) else {
            return nil
        }
        self.format = tournament_format
        return nil
    }
    init(){
        self.format = tournament_format.singleElimination
    }
    init(format:tournament_format){
        self.format = format
    }
    
    func toJSON() -> JSON? {
        return nil
    }
    func save()->Bool{
                return false
    }
}
