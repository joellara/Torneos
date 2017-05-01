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
    
    var torneoPadre: Tournament!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        torneoPadre = Tournament(format: Tournament.tournament_format.singleElimination)
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
    }
    
    func loadTournamentWithID(){
        let matches = torneoPadre.matches!
        var currRoundW = 1
        var currRoundL = 1
        var roundMatches: Array<TournamentMatches> = []
        for m in matches{
            if(m.round != currRoundW && m.seed == 1){
                currRoundW = m.round
                drawMatch(matchesToDraw: roundMatches, upperBracket: true)
                roundMatches.removeAll()
            }
            else{
                if(m.seed == 2 && m.round != currRoundL){
                    currRoundL = m.round
                    drawMatch(matchesToDraw: roundMatches, upperBracket: false)
                    roundMatches.removeAll()
                }
            }
            roundMatches.append(m)
        }
    }
    
    func drawMatch(matchesToDraw: Array<TournamentMatches>, upperBracket: Bool){
        let myVerticalStackView = UIStackView()
        myVerticalStackView.distribution = .fillEqually
        myVerticalStackView.axis = .vertical
        myVerticalStackView.spacing = 10
        
        for index in 0..<matchesToDraw.count {
            let matchToShow = matchesToDraw[index]
            let colorToFill = UIColor.darkGray
            let myMatchView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
            myMatchView.backgroundColor = UIColor.darkGray
            
            var button = UIButton(type: UIButtonType.custom) as UIButton
            button.setTitle("\(matchToShow.players[0]): \(matchToShow.result![0])", for: UIControlState.normal)
            button.setTitleColor(UIColor.black, for: UIControlState.normal)
            button.addTarget(self, action: #selector(self.buttonAction(sender:)), for: UIControlEvents.touchUpInside)
            
            var buttonFrame = button.frame;
            buttonFrame.size = CGSize(width: 100, height: 30)
            button.frame = buttonFrame;
            button.backgroundColor = colorToFill
            if(matchToShow.result![0] == 1){
                button.backgroundColor = UIColor.lightGray
            }
            myVerticalStackView.addArrangedSubview(button)
            
            button = UIButton(type: UIButtonType.custom) as UIButton
            button.setTitle("\(matchToShow.players[1]): \(matchToShow.result![1])", for: UIControlState.normal)
            button.setTitleColor(UIColor.black, for: UIControlState.normal)
            button.addTarget(self, action: #selector(self.buttonAction(sender:)), for: UIControlEvents.touchUpInside)
            
            buttonFrame = button.frame;
            buttonFrame.size = CGSize(width: 100, height: 30)
            button.frame = buttonFrame;
            button.backgroundColor = colorToFill
            if(matchToShow.result![1] == 1){
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
    
}
