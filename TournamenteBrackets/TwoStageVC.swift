//
//  TwoStageVC.swift
//  TournamenteBrackets
//
//  Created by Joel Lara Quintana on 14/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit

class TwoStageVC: KeyboardViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    let tipoTorneo = ["Single Elimination", "Double Elimination","Round Robin"]
    
    @IBOutlet weak var finalStageGroupNumberTxt: UITextField!
    @IBOutlet weak var finalStageGroupNumberLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var groupNumberTxt: UITextField!
    @IBOutlet weak var groupNumberLabel: UILabel!
    var tournament:Tournament!
    var keyboard = false
    
    override func viewDidLoad() {
        groupNumberTxt.layer.borderColor = UIColor.red.cgColor
        finalStageGroupNumberTxt.layer.borderColor = UIColor.red.cgColor
        
        self.tournament.firstStage = Tournament.tournamentFormat.SingleElimination
        self.tournament.secondStage = Tournament.tournamentFormat.SingleElimination
        
    }
    func numberOfComponents(in pickerView:	UIPickerView)->Int {
        return 1
    }
    func pickerView(_ pickerView:UIPickerView,numberOfRowsInComponent component:Int)->Int{
        return tipoTorneo.count
    }
    func pickerView(_ pickerView:UIPickerView,titleForRow row:	Int, forComponent component:Int)->String?{
        return tipoTorneo[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            if(tipoTorneo[row] == "Round Robin"){
                groupNumberTxt.isEnabled = true
                groupNumberLabel.textColor = UIColor(white: 0, alpha: 1)
            }else{
                groupNumberTxt.isEnabled = false
                groupNumberTxt.layer.borderWidth = 0.0
                groupNumberLabel.textColor = UIColor(white: 0.7, alpha: 1)
            }
            switch row {
            case 0:
                self.tournament.firstStage = Tournament.tournamentFormat.SingleElimination
            case 1:
                self.tournament.firstStage = Tournament.tournamentFormat.DoubleElimination
            case 2:
                self.tournament.firstStage = Tournament.tournamentFormat.RoundRobin
            default:
                break
            }
        }else{
            if(tipoTorneo[row] == "Round Robin"){
                finalStageGroupNumberTxt.isEnabled = true
                finalStageGroupNumberLabel.textColor = UIColor(white: 0, alpha: 1)
            }else{
                finalStageGroupNumberTxt.isEnabled = false
                finalStageGroupNumberTxt.layer.borderWidth = 0.0
                finalStageGroupNumberLabel.textColor = UIColor(white: 0.7, alpha: 1)
            }
            switch row {
            case 0:
                self.tournament.secondStage = Tournament.tournamentFormat.SingleElimination
            case 1:
                self.tournament.secondStage = Tournament.tournamentFormat.DoubleElimination
            case 2:
                self.tournament.secondStage = Tournament.tournamentFormat.RoundRobin
            default:
                break
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            textField.layer.borderWidth = 0.0
        }else{
            textField.layer.borderWidth = 0.0
        }
    }

    
    @IBAction func toBrackets(_ sender: UIButton) {
        var error = false
        if groupNumberTxt.isEnabled && (groupNumberTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            groupNumberTxt.layer.borderWidth = 1.0
            error = true
        }
        if finalStageGroupNumberTxt.isEnabled && (finalStageGroupNumberTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            finalStageGroupNumberTxt.layer.borderWidth = 1.0
            error = true
        }
        if !error {
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BracketsVCID") as? BracketsVC {
                if let navigator = self.navigationController {
                    viewController.tournament = self.tournament
                    navigator.popToRootViewController(animated: false)
                    navigator.pushViewController(viewController, animated: false)
                }else{
                    print("No navigator")
                }
            }else{
                print("No encontró BracketVCID")
            }
        }
    }
}
