//
//  KeyboardViewController.swift
//  KeyboardViewController
//
//  Created by Dan Beaulieu on 9/3/16.
//  Copyright © 2016 Dan Beaulieu. All rights reserved.
//

import UIKit

class KeyboardViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    private var activeField: UITextField?
    private var distanceMoved: CGFloat = 0
    private var sizeFields:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTap(_:)))
        tap.delegate = self
        
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tap)
        
    }
    
    func backgroundTap(_ sender: UITapGestureRecognizer? = nil) {
        dismissKeyboard()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: view.window)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: view.window)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: view.window)
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + self.distanceMoved)
            self.distanceMoved = 0
        })
        
    }
    
    func keyboardWillShow(_ notification: Notification) {
        guard self.activeField != nil else { assertionFailure("this should never fail"); return }
        
        
        if let userInfo = notification.userInfo,
            let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size {
            
            var aRect : CGRect = self.view.frame
            aRect.size.height -= keyboardSize.height
            
            if distanceMoved == 0  {
                distanceMoved = keyboardSize.height
                UIView.animate(withDuration: 1, animations: { () -> Void in
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - self.distanceMoved)
                })
            }
            
        }
    }
    
    func setDelegates(_ fields: AnyObject...) {
        for item in fields {
            if let textField = item as? UITextField {
                textField.delegate = self
                sizeFields += textField.frame.maxY - textField.frame.minY
            }
            if let textView = item as? UITextView {
                textView.delegate = self
                sizeFields += textView.frame.maxY - textView.frame.minY
            }
        }
    }
    
    override func dismissKeyboard () {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}


