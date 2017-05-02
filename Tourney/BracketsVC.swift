//
//  bracketsVC.swift
//  MyBrackets
//
//  Created by Joel Lara Quintana on 20/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit

class BracketsVC: UIViewController {
    var tournamentMaster:TournamentMaster!
    
    @IBOutlet weak var currentStage: UISegmentedControl!
    @IBOutlet weak var fullBracketView: UIStackView!
    
    var Wmatches: Array<TournamentMatches> = []
    var Lmatches: Array<TournamentMatches> = []
    var mainStackView = UIStackView()
    var secondaryStackView = UIStackView()
    var colores = [UIColor.lightGray,UIColor.gray]
    
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
        
        loadTournamentWithID()
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        refreshData()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        saveData()
    }
    
    func loadTournamentWithID(){
        let matches = tournamentBrackets.matches!
        var currRoundW = 1
        var currRoundL = 1
        var currSeed = 1
        
        //print(tournamentBrackets.participants)
        
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
            drawMatch(matchesToDraw: roundMatches, upperBracket: false)
        }
        fullBracketView.addArrangedSubview(mainStackView)
        fullBracketView.addArrangedSubview(secondaryStackView)
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
        let buttonText = String(describing: sender.titleLabel!.text!)
        var arr = buttonText.components(separatedBy: " ")
        if arr[0] == "0:" || arr[0] == "-1:"{
            return
        }
        var num = 0
        sender.backgroundColor = UIColor.darkGray
        if arr[1] == "0"{
            sender.backgroundColor = UIColor.lightGray
            num = 1
        }
        sender.setTitle("\(arr[0]) \(num)", for: UIControlState.normal)
    }
    
    func clearBracket(){
        for v in fullBracketView.subviews{
            v.removeFromSuperview()
        }
    }
    
    func saveData(){
        //Mandar al servidor los nuevos datos
        /*Re construccion de matches a partir de la lectura de los matches*/
        var newResults: Array<TournamentMatches> = []
        
        var currentRound = 0
        var roundNumber = 1
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
                        tempPlayer2 = (playerInfo.titleLabel!.text!).components(separatedBy: ": ")
                        let matchNumber = Int(floor(Double(playerNumber/2)))+1
                        
                        var newSeed = 1
                        var newRound = roundNumber
                        var newMatch = matchNumber
                        var player1 = Int(tempPlayer1[0]) ?? 0
                        var player2 = Int(tempPlayer2[0]) ?? 0
                        var newplayers = [player1,player2]
                        var score1 = Int(tempPlayer1[1]) ?? 0
                        var score2 = Int(tempPlayer2[1]) ?? 0
                        
                        var newScores = [score1,score2]

                        
                        let tempResult = TournamentMatches(nSeed: newSeed, nRound: newRound, nMatch: newMatch, nPlayers: newplayers as! [Int], nResults: newScores)
                        
                        newResults.append(tempResult)
                    }
                }
                playerNumber += 1
            }
            roundNumber += 1
        }
        
        currentRound = 0
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
                        tempPlayer2 = (playerInfo.titleLabel!.text!).components(separatedBy: ": ")
                        let matchNumber = Int(floor(Double(playerNumber/2)))+1
                        
                        var newSeed = 2
                        var newRound = roundNumber
                        var newMatch = matchNumber
                        var player1 = Int(tempPlayer1[0]) ?? 0
                        var player2 = Int(tempPlayer2[0]) ?? 0
                        var newplayers = [player1,player2]
                        var score1 = Int(tempPlayer1[1]) ?? 0
                        var score2 = Int(tempPlayer2[1]) ?? 0
                        
                        var newScores = [score1,score2]
                        
                        let tempResult = TournamentMatches(nSeed: newSeed, nRound: newRound, nMatch: newMatch, nPlayers: newplayers as! [Int], nResults: newScores)
                        
                        newResults.append(tempResult)
                    }
                }
                playerNumber += 1
            }
            roundNumber += 1
        }

        var saveData = tournamentSaveData(nId: "2", nApi_key: "2", nResults: newResults)
        print("Imprimiendo JSON?")
        print(saveData.toString())
        
    }
    
    func refreshData(){
        //Recuperar el torneo, y volver a cargar las vistas...
        /*
        tournamentBrackets = newShit
        clearBracket()
        loadTournamentWithID()
         */
    }
}

struct tournamentSaveData {
    
    var _id:String
    var api_key:String
    var results:[TournamentMatches]
    
    init (nId: String,nApi_key:String,nResults: [TournamentMatches]) {
        self._id = nId
        self.api_key = nApi_key
        self.results = nResults
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
}

