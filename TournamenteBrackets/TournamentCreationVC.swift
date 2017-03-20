//
//  TournamenteCreationVC.swift
//  TournamenteBrackets
//
//  Created by Joel Lara Quintana on 31/01/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

class TournamentCreationVC: UIViewController,UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tournamentName: UITextField!
    @IBOutlet weak var descriptionNameTxt: UITextView!
    @IBOutlet weak var gameName: UITextField!
    @IBOutlet weak var privacySC: UISegmentedControl!
    var starEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        descriptionNameTxt.layer.borderColor = UIColor(red: 0.01, green: 0.01, blue: 0.01, alpha: 1.0).cgColor
        descriptionNameTxt.layer.borderWidth = 1.0
        descriptionNameTxt.layer.cornerRadius = 5
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            tournamentName.resignFirstResponder()
            gameName.becomeFirstResponder()
        case 1:
            gameName.resignFirstResponder()
            descriptionNameTxt.becomeFirstResponder()
        case 2:
            descriptionNameTxt.resignFirstResponder()
        default:
            break
        }
        return false
    }
    @IBAction func segmentedTouch() {
        self.dismissKeyboard()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0.0
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
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderColor = UIColor(red: 0.01, green: 0.01, blue: 0.01, alpha: 1.0).cgColor
        if !starEditing {
            textView.text = ""
            textView.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            starEditing = true
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        adjustInsetForKeyboardShow(show: true, notification: notification)
    }
    func keyboardWillHide(notification: NSNotification) {
        adjustInsetForKeyboardShow(show:false, notification: notification)
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
            error = true
        }
        return !error
    }
}

