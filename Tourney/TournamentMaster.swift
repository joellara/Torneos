//
//  TournamentMaster.swift
//  Tourney
//
//  Created by Joel Lara Quintana on 29/04/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import Foundation
import Gloss

struct createNewTournament : Decodable {
    var valid:Bool
    var created:Bool
    init?(json: JSON) {
        guard let valid:Bool = "valid" <~~ json,
            let created:Bool = "created" <~~ json else {
                return nil
        }
        self.valid = valid
        self.created = created
    }
}

struct rSearchTournament :  Decodable {
    var valid:Bool
    var found:Bool
    var message:String?
    var tournament:TournamentMaster?
    
    init?(json: JSON) {
        guard let valid:Bool = "valid" <~~ json,
            let found:Bool = "found" <~~ json else {
                return nil
        }
        if found {
            guard let tourn:TournamentMaster = "tournament" <~~ json else { return nil }
            self.tournament = tourn
        }
        self.message = "message" <~~ json
        self.valid = valid
        self.found = found
    }
}

struct TournamentMaster : Decodable, Glossy {
    let _id:String?
    let name:String
    let description:String
    let tournamentType:tournament_type
    let game:String
    var finalStageID:String? //ID
    var groupStageID:String? //ID
    var groupStage:Tournament?
    var finalStage:Tournament?
    var participants:[String]?
    
    enum tournament_type:String {
        case singleStage = "single_stage"
        case twoStage = "two_stage"
        
        static func decodeTournamentType(key: String, json: JSON) -> TournamentMaster.tournament_type? {
            
            guard let tournament_type: String = key <~~ json else {
                return nil
            }
            if let type = TournamentMaster.tournament_type(rawValue: tournament_type) {
                return type
            }
            return nil
        }
    }
    init?(json: JSON) {
        guard let name: String = "name" <~~ json,
            let id:String = "_id" <~~ json,
            let game: String = "game" <~~ json,
            let description: String = "description" <~~ json,
            let tournament_type = tournament_type.decodeTournamentType(key: "tournament_type", json: json),
            let group_stage_id: String = "group_stage_id" <~~ json
        else {
            return nil
        }
        self._id = id
        self.name = name
        self.description = description
        self.game = game
        self.tournamentType = tournament_type
        self.groupStageID = group_stage_id
        if tournament_type == .twoStage {
            guard let final:String = "final_stage_id" <~~ json else { return nil }
            self.finalStageID = final
        }
        self.groupStage = nil
        self.finalStage = nil
        self.participants = nil
    }
    
    init(name:String,tournamentType:TournamentMaster.tournament_type,game:String,description:String) {
        self.name = name
        self.description = description
        self.tournamentType = tournamentType
        self.game = game
        self._id = nil

    }
    func isValidToSend()->Bool{
        if self.tournamentType == tournament_type.twoStage && self.finalStage == nil {
            return false
        }
        if self.participants == nil {
            return false
        }
        if self.groupStage == nil {
            return false
        }
        return true
    }
    
    func toJSON() -> JSON? {
        guard self.isValidToSend() else {
            return nil
        }
        let prefs = UserDefaults.standard
        let api_key = prefs.string(forKey: "api_key")
        return jsonify([
            "name" ~~> self.name,
            "description" ~~> self.description,
            "tournament_type" ~~> self.tournamentType.rawValue,
            "participants" ~~> self.participants!,
            "game" ~~> self.game,
            "final_stage_type" ~~> self.finalStage?.tournament_type,
            "group_stage_type" ~~> self.groupStage?.tournament_type,
            "api_key"~~>api_key!
            ])
    }
    static func getTournaments(withId id:String)->[TournamentMaster]?{
        return nil
    }

}
