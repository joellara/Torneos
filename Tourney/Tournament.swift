//
//  Tournament.swift
//  MyBrackets
//
//  Created by Joel Lara Quintana on 20/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import Foundation
import Gloss



struct TournamentMatches : Decodable, Glossy {
    var seed:Int
    var round:Int
    var match:Int
    var players:[Int]
    var result:[Int]?
    
    init?(json: JSON) {
        guard let seed:Int = "id.s" <~~ json,
            let round:Int = "id.r" <~~ json,
            let match:Int  = "id.m" <~~ json,
            let p:[Int] = "p" <~~ json
            else { return nil }
        self.seed = seed
        self.round = round
        self.match = match
        self.players = p
        self.result = "m" <~~ json
    }
    func toJSON() -> JSON? {
        return nil
    }
    
}

struct Tournament : Decodable, Glossy {
    
    
    var _id:String?
    var parent_id:String?
    var api_key:String?
    var tournament_type:Tournament.tournament_format
    var started:Bool?
    var participants: [String]?
    var matches:[TournamentMatches]?
    
    
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
        guard let tournament_type = tournament_format.decodeTournamentFormat(key: "tournament_type", json: json),
            let id:String = "_id" <~~ json,
            let parent_id:String = "parent_id" <~~ json,
            let api_key:String = "api_key" <~~ json,
            let started:Bool = "started" <~~ json,
            let participants:[String] = "participants" <~~ json,
            let matches:[TournamentMatches] = "matches" <~~ json
        else {
            return nil
        }
        self._id = id
        self.parent_id = parent_id
        self.api_key = api_key
        self.started = started
        self.participants = participants
        self.matches = matches
        self.tournament_type = tournament_type
    }

    init(format:tournament_format = tournament_format.singleElimination){
        self.tournament_type = format
        self.parent_id = nil
        self.api_key = nil
        self.started = nil
        self.matches = nil
    }
    
    func toJSON() -> JSON? {
        return nil
    }
}
