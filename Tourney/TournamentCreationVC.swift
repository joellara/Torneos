//
//  TournamenteCreationVC.swift
//  TournamenteBrackets
//
//  Created by Joel Lara Quintana on 31/01/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit

class TournamentCreationVC: KeyboardViewController,UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tournamentName: UITextField!
    @IBOutlet weak var descriptionNameTxt: UITextView!
    @IBOutlet weak var gameName: UITextField!
    @IBOutlet weak var stageSC: UISegmentedControl!
    
    
    var starEditing = false
    var keyboard = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionNameTxt.layer.borderColor = UIColor(red: 0.01, green: 0.01, blue: 0.01, alpha: 1.0).cgColor
        descriptionNameTxt.layer.borderWidth = 1.0
        descriptionNameTxt.layer.cornerRadius = 5
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            gameName.becomeFirstResponder()
        case 1:
            descriptionNameTxt.becomeFirstResponder()
        case 2:
            descriptionNameTxt.resignFirstResponder()
        default:
            break
        }
        return false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0.0
    }
    @IBAction func textFieldEditingEnd(_ textField: UITextField) {
        textField.layer.borderWidth = 0.0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderColor = UIColor(red: 0.01, green: 0.01, blue: 0.01, alpha: 1.0).cgColor
        if !starEditing {
            textView.text = ""
            textView.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            starEditing = true
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var error = false
        if (gameName.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            gameName.layer.borderWidth = 1.0
            gameName.layer.cornerRadius = 5
            gameName.layer.borderColor = UIColor.red.cgColor
            error = true
        }
        if(tournamentName.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            tournamentName.layer.borderWidth = 1.0
            tournamentName.layer.cornerRadius = 5
            tournamentName.layer.borderColor = UIColor.red.cgColor
            error = true
        }
        if(descriptionNameTxt.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) || !starEditing {
            descriptionNameTxt.layer.borderWidth = 1.0
            descriptionNameTxt.layer.borderColor = UIColor.red.cgColor
            //setError(field: descriptionNameTxt, state: true)
            error = true
        }
        return !error
    }
    
    private func setError(field: UIView, state:Bool){
        if state {
            field.layer.borderWidth = 1.0
            field.layer.borderColor = UIColor.red.cgColor
        }else{
            field.layer.borderWidth = 0.0
            field.layer.borderColor = UIColor.red.cgColor
        }

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? TournamentTypeVC {
            let type:TournamentMaster.tournament_type
            if stageSC.selectedSegmentIndex == 0 {
                type = .singleStage
            }else{
                type = .twoStage
            }
            let tournamentMaster = TournamentMaster(name: self.tournamentName.text!,tournamentType:type, game: self.gameName.text!, description: self.descriptionNameTxt.text!)
            controller.tournamentMaster = tournamentMaster
        }
    }
}

