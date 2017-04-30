//
//  SignInVC.swift
//  Tourney
//
//  Created by Joel Lara Quintana on 28/04/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
import Alamofire
import ReachabilitySwift
class SignInVC: KeyboardViewController {

    var keyboardOnScreen = false
    
    @IBOutlet weak var emailTxt: UITextField!
    
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    
    @IBOutlet weak var createAccountBtn: UIButton!
    
    @IBOutlet weak var signInBtn: UIButton!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    let reachability = Reachability()
    var requestOngoing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try? reachability?.startNotifier() ?? print("No se pudo iniciar reachability")
        self.monitorNetwork()
        // Do any additional setup after loading the view.
    }
    
    private func monitorNetwork (){
        reachability?.whenUnreachable = { reachability in
            print("Not reachable")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismissVC(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        if (emailTxt.text?.isEmpty)! {
            self.displayAlert(title:"Email obligatorio",message: "Ingresa tu dirección de correo")
        }else if !isValidEmail(emailTxt.text!) {
            self.displayAlert(title:"Email válido",message: "Ingresa una dirección de correo válida")
        }else if (passwordTxt.text?.isEmpty)! {
            self.displayAlert(title:"Contraseña requerida",message: "Ingresa tu contraseña")
        }else if(requestOngoing == false && (reachability?.isReachable)!){
            makeLogin(email: emailTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: passwordTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines))
        }else if(!(reachability?.isReachable)!){
            self.displayAlert(title: "Internet", message: "Se necesita conexión a internet")
        }
        else{
            print("Error")
        }
    }
    
    func makeLogin(email:String,password:String){
        //setting varibles and activity indicator
        activity.isHidden = false
        activity.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        requestOngoing = true
        
        
        
        disableFields()
        
        //making request and parsing it
        
        
        let parameters = ["email":email,"password":password]
        Alamofire.request("https://tourneyserver.herokuapp.com/auth/login/",method:.post,parameters:parameters,encoding:JSONEncoding.default).responseJSON { response in
            
            
            if response.response?.statusCode == 200 {
                if let json = response.result.value, let jsonArr = json as? [String:Any], let user = UserSignIn(json: jsonArr){
                    if user.valid && user.loggedIn {
                        let prefs = UserDefaults.standard
                        prefs.set(user.name!, forKey: "user_name")
                        prefs.set(user.email, forKey: "user_email")
                        prefs.set(user.api_key, forKey: "api_key")
                        prefs.synchronize()
                        self.dismiss(animated: true, completion: nil)
                    }else if(user.valid && !user.loggedIn){
                        self.displayAlert(title: "Error", message: user.message!)
                    }
                }
            }else{
                self.displayAlert(title: "Error", message: "Hubo un problema intentelo más tarde")
            }
            self.requestOngoing = false
            self.activity.isHidden = true
            self.activity.stopAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.enableFields()
        }
        
        
    }
    
    private func disableFields(){
        self.emailTxt.isEnabled = false
        self.passwordTxt.isEnabled = false
        self.signInBtn.isEnabled = false
        self.forgotPasswordBtn.isEnabled = false
        self.createAccountBtn.isEnabled = false
    }
    private func enableFields(){
        self.emailTxt.isEnabled = true
        self.passwordTxt.isEnabled = true
        self.signInBtn.isEnabled = true
        self.forgotPasswordBtn.isEnabled = true
        self.createAccountBtn.isEnabled = true
    }
    
    
    
    func isValidEmail(_ email: String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = email as NSString
            let results = regex.matches(in: email, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0 {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        if (emailTxt.text?.isEmpty)! {
            self.displayAlert(title: "Email", message: "Ingresa tu correo para poder mandarte un email")
        }else if !isValidEmail(emailTxt.text!) {
            self.displayAlert(title: "Email", message: "Ingresa un email válido")
        }else{
            serverForgoPassword()
        }
    }
    
    func serverForgoPassword(){
        
    }
    
    @IBAction func createAccount(_ sender: UIButton) {
        
    }
}
extension SignInVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            self.passwordTxt.becomeFirstResponder()
        case 1:
            self.passwordTxt.resignFirstResponder()
        default:
            break
        }
        return true
    }
}
