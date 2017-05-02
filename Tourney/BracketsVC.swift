//
//  bracketsVC.swift
//  MyBrackets
//
//  Created by Joel Lara Quintana on 20/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
import Gloss
import Alamofire

class BracketsVC: KeyboardViewController {
    var tournamentMaster:TournamentMaster!
    
    @IBOutlet weak var currentStage: UISegmentedControl!
    @IBOutlet weak var fullBracketView: UIStackView!

    var mainStackView = UIStackView()
    var secondaryStackView = UIStackView()
    var colores = [UIColor.lightGray,UIColor.gray]
    let prefs = UserDefaults.standard
    var editable = false
    
    var groupStageID: String = ""
    var finalStageID: String = ""
    var currentNumberStage: Int = 0
    var currentStageID: String = ""
    
    var groupStageFinished: Bool = false
    
    var tournamentBrackets: Tournament!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainStackView.axis = .horizontal
        secondaryStackView.axis = .horizontal
        
        fullBracketView.axis = .vertical
        
        fullBracketView.distribution = .fillEqually
        fullBracketView.spacing = 5.0
        fullBracketView.autoresizesSubviews = false
        
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = 5.0
        mainStackView.autoresizesSubviews = false
        
        secondaryStackView.distribution = .fillEqually
        secondaryStackView.spacing = 5.0
        secondaryStackView.autoresizesSubviews = false
        
        groupStageID = tournamentBrackets._id!
        finalStageID = tournamentBrackets.sibling_id ?? ""
        
        currentStageID = groupStageID
        
        if(tournamentBrackets.sibling_id == nil ){
            groupStageFinished = true
            currentStage.selectedSegmentIndex = 1
            currentStage.setEnabled(false, forSegmentAt: 0)
        }
        
        if let api = prefs.string(forKey: "api_key"){
            if(api == tournamentBrackets.api_key){
                editable = true
            }
        }
        
        loadTournamentWithID()
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        refreshData()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if(editable){
            saveData()
        }
    }
    
    func loadTournamentWithID(){
        let matches = tournamentBrackets.matches!
        var currRoundW = 1
        var currRoundL = 1
        var currSeed = 1
        
        var roundMatches: Array<TournamentMatches> = []
        for m in matches{
            if(m.round != currRoundW && m.seed == 1){
                currRoundW = m.round
                drawMatch(matchesToDraw: roundMatches, upperBracket: true)
                roundMatches.removeAll()
            }
            else{
                if(currSeed != m.seed){
                    currSeed = m.seed
                    drawMatch(matchesToDraw: roundMatches, upperBracket: true)
                    roundMatches.removeAll()
                }
                if(m.round != currRoundL && m.seed == 2){
                    currRoundL = m.round
                    drawMatch(matchesToDraw: roundMatches, upperBracket: false)
                    roundMatches.removeAll()
                }
            }
            roundMatches.append(m)
        }
        if(roundMatches.count > 0){
            if(currSeed == 1){
                drawMatch(matchesToDraw: roundMatches, upperBracket: true)
            }
            else{
                drawMatch(matchesToDraw: roundMatches, upperBracket: false)
            }
        }
        fullBracketView.addArrangedSubview(mainStackView)
        if(secondaryStackView.subviews.count > 0){
            fullBracketView.addArrangedSubview(secondaryStackView)
        }
    }
    
    func drawMatch(matchesToDraw: Array<TournamentMatches>, upperBracket: Bool){
        let myVerticalStackView = UIStackView()
        myVerticalStackView.distribution = .fillEqually
        myVerticalStackView.axis = .vertical
        myVerticalStackView.spacing = 10
        
        for index in 0..<matchesToDraw.count {
            let matchToShow = matchesToDraw[index]
            var finalResults = [0,0]
            if matchToShow.result != nil {
                finalResults = matchToShow.result!
            }
            
            let colorToFill = UIColor.darkGray
            let myMatchView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
            myMatchView.backgroundColor = UIColor.darkGray
            var button = UIButton(type: UIButtonType.custom) as UIButton
            if(matchToShow.players[0] == 0){
                button.setTitle("0: \(finalResults[0])", for: UIControlState.normal)
            }
            else{
                if(matchToShow.players[0] == -1){
                    button.setTitle("-1: \(finalResults[0])", for: UIControlState.normal)
                }
                else{
                    button.setTitle("\(tournamentBrackets.participants![matchToShow.players[0]-1]): \(finalResults[0])", for: UIControlState.normal)
                }
                
            }
            
            button.setTitleColor(UIColor.black, for: UIControlState.normal)
            button.addTarget(self, action: #selector(self.buttonAction(sender:)), for: UIControlEvents.touchUpInside)
            var buttonFrame = button.frame;
            buttonFrame.size = CGSize(width: 100, height: 30)
            button.frame = buttonFrame;
            button.backgroundColor = colorToFill
            if(finalResults[0] == 1){
                button.backgroundColor = UIColor.lightGray
            }
            myVerticalStackView.addArrangedSubview(button)
            
            
            button = UIButton(type: UIButtonType.custom) as UIButton
            if(matchToShow.players[1] == 0){
                button.setTitle("0: \(finalResults[0])", for: UIControlState.normal)
            }
            else{
                if(matchToShow.players[1] == -1){
                    button.setTitle("-1: \(finalResults[1])", for: UIControlState.normal)
                }
                else{
                    button.setTitle("\(tournamentBrackets.participants![matchToShow.players[1]-1]): \(finalResults[1])", for: UIControlState.normal)
                }
            }
            button.setTitleColor(UIColor.black, for: UIControlState.normal)
            button.addTarget(self, action: #selector(self.buttonAction(sender:)), for: UIControlEvents.touchUpInside)
            buttonFrame = button.frame;
            buttonFrame.size = CGSize(width: 100, height: 30)
            button.frame = buttonFrame;
            button.backgroundColor = colorToFill
            if(finalResults[1] == 1){
                button.backgroundColor = UIColor.lightGray
            }
            myVerticalStackView.addArrangedSubview(button)
        }
        if(upperBracket){
            mainStackView.addArrangedSubview(myVerticalStackView)
        }
        else{
            secondaryStackView.addArrangedSubview(myVerticalStackView)
        }
    }
    
    func buttonAction(sender:UIButton!){
        if(!editable){
            return
        }
        let buttonText = String(describing: sender.titleLabel!.text!)
        var arr = buttonText.components(separatedBy: ": ")
        if arr[0] == "0" || arr[0] == "-1"{
            return
        }
        var num = 0
        sender.backgroundColor = UIColor.darkGray
        if arr[1] == "0"{
            sender.backgroundColor = UIColor.lightGray
            num = 1
        }
        sender.setTitle("\(arr[0]): \(num)", for: UIControlState.normal)
    }
    
    func clearBracket(){
        for v in fullBracketView.subviews{
            v.removeFromSuperview()
        }
        for v in mainStackView.subviews{
            v.removeFromSuperview()
        }
        for v in secondaryStackView.subviews{
            v.removeFromSuperview()
        }
    }
    
    @IBAction func changeCurrentState(_ sender: Any) {
        if(currentNumberStage == currentStage.selectedSegmentIndex){
            return
        }
        if(currentStage.selectedSegmentIndex == 1){
            if(!tournamentBrackets.finished!){
                return
            }
            currentStageID = finalStageID
        }
        else{
            currentStageID = groupStageID
        }
        currentNumberStage = currentStage.selectedSegmentIndex
        refreshData()
    }
    
    func saveData(){
        //Mandar al servidor los nuevos datos
        /*Re construccion de matches a partir de la lectura de los matches*/
        var newResults: Array<TournamentMatches> = []
        
        var roundNumber = 1
        var indexMatch = 0
        for round in mainStackView.subviews{
            var playerNumber = 0
            var tempPlayer1: Array<String> = []
            var tempPlayer2: Array<String> = []
            for player in round.subviews{
                if let playerInfo = player as? UIButton{
                    if playerNumber%2 == 0{
                        tempPlayer1 = (playerInfo.titleLabel!.text!).components(separatedBy: ": ")
                    }
                    else{
                        let sp1 = tournamentBrackets.matches?[indexMatch].result?[0] ?? 0
                        let sp2 = tournamentBrackets.matches?[indexMatch].result?[1] ?? 0
                        
                        tempPlayer2 = (playerInfo.titleLabel!.text!).components(separatedBy: ": ")
                        let matchNumber = Int(floor(Double(playerNumber/2)))+1
                        
                        let newSeed = 1
                        let newRound = roundNumber
                        let newMatch = matchNumber
                        let player1 = Int(tempPlayer1[0]) ?? 0
                        let player2 = Int(tempPlayer2[0]) ?? 0
                        let newplayers = [player1,player2]
                        let score1 = Int(tempPlayer1[1]) ?? 0
                        let score2 = Int(tempPlayer2[1]) ?? 0
                        
                        let newScores = [score1,score2]

                        let tempResult = TournamentMatches(nSeed: newSeed, nRound: newRound, nMatch: newMatch, nPlayers: newplayers, nResults: newScores)
                        if(newplayers[0] != -1 && newplayers[1] != -1){
                            if(sp1 == sp2 && score1 != score2){
                                newResults.append(tempResult)
                            }
                        }
                        indexMatch += 1
                    }
                }
                playerNumber += 1
            }
            roundNumber += 1
        }
        
        roundNumber = 1
        for round in secondaryStackView.subviews{
            var playerNumber = 0
            var tempPlayer1: Array<String> = []
            var tempPlayer2: Array<String> = []
            for player in round.subviews{
                if let playerInfo = player as? UIButton{
                    if playerNumber%2 == 0{
                        tempPlayer1 = (playerInfo.titleLabel!.text!).components(separatedBy: ": ")
                    }
                    else{
                        let sp1 = tournamentBrackets.matches?[indexMatch].result?[0] ?? 0
                        let sp2 = tournamentBrackets.matches?[indexMatch].result?[1] ?? 0
                        
                        tempPlayer2 = (playerInfo.titleLabel!.text!).components(separatedBy: ": ")
                        let matchNumber = Int(floor(Double(playerNumber/2)))+1
                        
                        let newSeed = 2
                        let newRound = roundNumber
                        let newMatch = matchNumber
                        let player1 = Int(tempPlayer1[0]) ?? 0
                        let player2 = Int(tempPlayer2[0]) ?? 0
                        let newplayers = [player1,player2]
                        let score1 = Int(tempPlayer1[1]) ?? 0
                        let score2 = Int(tempPlayer2[1]) ?? 0
                        
                        let newScores = [score1,score2]
                        
                        let tempResult = TournamentMatches(nSeed: newSeed, nRound: newRound, nMatch: newMatch, nPlayers: newplayers, nResults: newScores)
                        if(newplayers[0] != -1 && newplayers[1] != -1){
                            if(sp1 == sp2 && score1 != score2){
                                newResults.append(tempResult)
                            }
                        }
                        indexMatch += 1
                    }
                }
                playerNumber += 1
            }
            roundNumber += 1
        }

        let saveData = tournamentSaveData(nId: tournamentBrackets._id!, nApi_key: tournamentBrackets.api_key!, nResults: newResults)
        let jsonObject = saveData.toJSON()
        
        //print(jsonObject ?? "No JSON")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var stringUrl = "https://tourneyserver.herokuapp.com/tournament/score/".appending(tournamentBrackets._id!)
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        
        let parameters = jsonObject
        Alamofire.request(stringUrl,method:.post,parameters:parameters,encoding:JSONEncoding.default).responseJSON { response in
            
            if response.response?.statusCode == 200 {
                if let json = response.result.value, let jsonArr = json as? [String:Any], let result = resultScore(json: jsonArr){
                    if result.valid && result.scored{
                        self.displayAlert(title: "Exito", message: "Se ha guardado el torneo en la base de datos. Para actualizar los resultados use el boton inferior izquierdo. Puede tomar unos minutos")
                    }
                }
            }
            else{
                self.displayAlert(title: "Error", message: "Hubo un problema intentelo más tarde")
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        
    }
    
    func refreshData(){
        
        clearBracket()
        let idToLoad = currentStageID
        
        var stringUrl = "https://tourneyserver.herokuapp.com/tournament/".appending(idToLoad)
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Alamofire.request(stringUrl, method:.get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            if response.response?.statusCode == 200 {
                if let json = response.result.value, let jsonArr = json as? JSON, let res = stateTournament(json: jsonArr) {
                    if res.valid && res.found {
                        self.tournamentBrackets = res.tournament!
                        self.loadTournamentWithID()
                    }else{
                        print("Should happen, but not found")
                    }
                }else{
                    self.displayAlert(title: "Error", message: "Tuvimos un error interno, inténtalo de nuevo más tarde")
                }
            }else{
                self.displayAlert(title: "Error", message: "Tuvimos un error interno, inténtalo de nuevo más tarde")
            }
        }
        
        DispatchQueue.main.async {
            //self.loadTournamentWithID()
        }
        //loadTournamentWithID()
    }
}

struct resultScore: Decodable {
    var valid: Bool
    var scored: Bool
    
    init?(json: JSON) {
        guard let valid:Bool = "valid" <~~ json,
            let scored:Bool = "scored" <~~ json
        else { return nil }
        self.valid = valid
        self.scored = scored
    }
}

struct matchesSaveData{
    var id: [String:Int]
    var score: [Int]
    
}

struct tournamentSaveData: Glossy {
    var _id:String
    var api_key:String
    var results:[TournamentMatches]
    
    init (nId: String,nApi_key:String,nResults: [TournamentMatches]) {
        self._id = nId
        self.api_key = nApi_key
        self.results = nResults
    }
    init?(json: JSON) {
        return nil
    }
    
    func toString() -> String {
        var result = "";
        result.append("[")
        result.append("id:\(_id),")
        result.append("api_key:\(api_key),")
        result.append("results:{")
        for match in results{
            result.append("id{s:\(match.seed),r:\(match.round),m:\(match.match)},p[\(match.result![0]),\(match.result![1])]")
        }
        result.append("}")
        result.append("]")
        return result
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "api_key" ~~> self.api_key,
            "results" ~~> self.results,
        ])
    }
}

