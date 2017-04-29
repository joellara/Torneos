//
//  KeyboardViewController.swift
//  KeyboardViewController
//
//  Created by Dan Beaulieu on 9/3/16.
//  Copyright © 2016 Dan Beaulieu. All rights reserved.
//

import UIKit

class KeyboardViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private var distanceMoved: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
    }
    
    //helper method
    func displayAlert(title:String,message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction!) in
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
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
    
    
    func dismissKeyboard () {
        view.endEditing(true)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
}


