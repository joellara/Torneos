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
    
    let tipoTorneo = ["Single Elimination", "Double Elimination","Round Robin"]
    
    override func viewDidLoad() {
       self.hideKeyboard()
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
        if(tipoTorneo[row] == "Round Robin"){
            groupNumberTxt.isEnabled = true
            groupNumberLabel.textColor = UIColor(white: 0, alpha: 1)
        }else{
            groupNumberTxt.isEnabled = false
            groupNumberLabel.textColor = UIColor(white: 0.7, alpha: 1)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        groupNumberTxt.resignFirstResponder()
        return true
    }
}
