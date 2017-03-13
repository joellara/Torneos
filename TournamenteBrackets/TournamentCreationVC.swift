//
//  TournamenteCreationVC.swift
//  TournamenteBrackets
//
//  Created by Joel Lara Quintana on 31/01/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit

class TournamentCreationVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBAction func crearTorneo(_ sender: UIButton) {
        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else {
                return
            }
        let keyboardFrame = value.cgRectValue
        let adjustmentHeight = (keyboardFrame.height + 30) * (show ? 1 : -1)
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.contentInset.top += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    func keyboardWillShow(notification: NSNotification) {
        adjustInsetForKeyboardShow(show: true, notification: notification)
    }
    func keyboardWillHide(notification: NSNotification) {
        adjustInsetForKeyboardShow(show:false, notification: notification)
    }
}

