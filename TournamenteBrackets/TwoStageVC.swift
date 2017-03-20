//
//  TwoStageVC.swift
//  TournamenteBrackets
//
//  Created by Joel Lara Quintana on 14/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
class TwoStageVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    let tipoTorneo = ["Single Elimination", "Double Elimination","Round Robin"]
    
    @IBOutlet weak var finalStageGroupNumberTxt: UITextField!
    @IBOutlet weak var finalStageGroupNumberLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var groupNumberTxt: UITextField!
    @IBOutlet weak var groupNumberLabel: UILabel!
    override func viewDidLoad() {
        self.hideKeyboard()
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
                groupNumberLabel.textColor = UIColor(white: 0.7, alpha: 1)
            }
        }else{
            if(tipoTorneo[row] == "Round Robin"){
                finalStageGroupNumberTxt.isEnabled = true
                finalStageGroupNumberLabel.textColor = UIColor(white: 0, alpha: 1)
            }else{
                finalStageGroupNumberTxt.isEnabled = false
                finalStageGroupNumberLabel.textColor = UIColor(white: 0.7, alpha: 1)
            }
        }
    }
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = value.cgRectValue
        let adjustmentHeight = (keyboardFrame.height +  20) * (show ? 1 : -1)
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    func keyboardWillShow(notification: NSNotification) {
        adjustInsetForKeyboardShow(show: true, notification: notification)
    }
    func keyboardWillHide(notification: NSNotification) {
        adjustInsetForKeyboardShow(show:false, notification: notification)
    }
}
