//
//  FormatVC.swift
//  TournamenteBrackets
//
//  Created by Joel Lara Quintana on 13/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
class SingleStageVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet weak var formatoPV: UIPickerView!
    @IBOutlet weak var groupNumberLabel: UILabel!
    @IBOutlet weak var groupNumberTxt: UITextField!
    var tournament:Tournament!
    
    let tipoTorneo = ["Single Elimination", "Double Elimination","Round Robin"]
    
    override func viewDidLoad() {
       self.hideKeyboard()
        groupNumberTxt.layer.borderColor = UIColor.red.cgColor
        self.tournament.firstStage = Tournament.tournamentFormat.SingleElimination
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
        if(tipoTorneo[row] == tipoTorneo[2]){
            groupNumberTxt.isEnabled = true
            groupNumberLabel.textColor = UIColor(white: 0, alpha: 1)
        }else{
            groupNumberTxt.isEnabled = false
            groupNumberLabel.textColor = UIColor(white: 0.7, alpha: 1)
            groupNumberTxt.layer.borderWidth = 0.0
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
    }
    @IBAction func toBrackets(_ sender: UIButton) {
        if groupNumberTxt.isEnabled && (groupNumberTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            groupNumberTxt.layer.borderWidth = 1.0
        }else{
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        groupNumberTxt.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        groupNumberTxt.layer.borderWidth = 0.0
    }
    
    
    
}
