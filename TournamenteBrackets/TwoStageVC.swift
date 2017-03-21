//
//  TwoStageVC.swift
//  TournamenteBrackets
//
//  Created by Joel Lara Quintana on 14/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit

class TwoStageVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    let tipoTorneo = ["Single Elimination", "Double Elimination","Round Robin"]
    
    @IBOutlet weak var finalStageGroupNumberTxt: UITextField!
    @IBOutlet weak var finalStageGroupNumberLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var groupNumberTxt: UITextField!
    @IBOutlet weak var groupNumberLabel: UILabel!
    var tournament:Tournament!

    
    override func viewDidLoad() {
        self.hideKeyboard()
        groupNumberTxt.layer.borderColor = UIColor.red.cgColor
        finalStageGroupNumberTxt.layer.borderColor = UIColor.red.cgColor
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
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
        }else{
            if(tipoTorneo[row] == "Round Robin"){
                finalStageGroupNumberTxt.isEnabled = true
                finalStageGroupNumberLabel.textColor = UIColor(white: 0, alpha: 1)
            }else{
                finalStageGroupNumberTxt.isEnabled = false
                finalStageGroupNumberTxt.layer.borderWidth = 0.0
                finalStageGroupNumberLabel.textColor = UIColor(white: 0.7, alpha: 1)
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
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = value.cgRectValue
        let adjustmentHeight = (keyboardFrame.height + 8) * (show ? 1 : -1)
        if show {
            scrollView.contentInset.bottom += adjustmentHeight
            scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
        }else{
            scrollView.contentInset.bottom = 8
            scrollView.scrollIndicatorInsets.bottom = 8
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
    func keyboardWillShow(notification: NSNotification) {
        adjustInsetForKeyboardShow(show: true, notification: notification)
    }
    func keyboardWillHide(notification: NSNotification) {
        adjustInsetForKeyboardShow(show:false, notification: notification)
    }
}
