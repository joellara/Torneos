//
//  SignInVC.swift
//  Tourney
//
//  Created by Joel Lara Quintana on 28/04/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit

class SignInVC: KeyboardViewController {

    var keyboardOnScreen = false
    
    @IBOutlet weak var emailTxt: UITextField!
    
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    
    @IBOutlet weak var createAccountBtn: UIButton!
    
    @IBOutlet weak var signInBtn: UIButton!
    
    
    override func viewDidLoad() {
        self.hideKeyboard()
        super.viewDidLoad()
        self.setDelegates(emailTxt,passwordTxt)
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismissVC(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signIn(_ sender: UIButton) {
    }
    
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        
    }
    
    @IBAction func createAccount(_ sender: UIButton) {
        
    }


}
