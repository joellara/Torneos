//
//  SignIn.swift
//  MyBrackets
//
//  Created by Joel Lara Quintana on 27/04/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var signBtn: UIButton!
    
    private let prefs = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.checkState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        checkState()
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    @IBAction func sign(_ sender: UIButton) {
        if prefs.bool(forKey: "loggedIn") {
            print("Should sign out")
        }else{
            performSegue(withIdentifier: "presentSignIn", sender: self)
        }
    }
    
    private func checkState(){
        if prefs.bool(forKey: "loggedIn") {
            self.signBtn.setTitle("Cerrar sesión", for: .normal)
        }else{
            self.signBtn.setTitle("Iniciar sesión", for: .normal)
            
        }
    }
    
    private func logOut(){
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
