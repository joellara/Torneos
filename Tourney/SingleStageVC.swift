//
//  FormatVC.swift
//  TournamenteBrackets
//
//  Created by Joel Lara Quintana on 13/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
class SingleStageVC: KeyboardViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var formatoPV: UIPickerView!
    var tournamentMaster:TournamentMaster!
    var tournament = Tournament()
    
    let tipoTorneo = ["Single Elimination", "Double Elimination","Round Robin"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        switch row {
        case 0:
            self.tournament.format = Tournament.tournament_format.singleElimination
        case 1:
            self.tournament.format = Tournament.tournament_format.doubleElimination
        case 2:
            self.tournament.format = Tournament.tournament_format.roundRobin
        default:
            break
        }
    }
    @IBAction func toBrackets(_ sender: UIButton) {

        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BracketsVCID") as? BracketsVC {
            if let navigator = self.navigationController {
                self.tournamentMaster.groupStage = self.tournament
                viewController.tournamentMaster = self.tournamentMaster
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
