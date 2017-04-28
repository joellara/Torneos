//
//  SignUpVC.swift
//  Tourney
//
//  Created by Joel Lara Quintana on 28/04/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
import ReachabilitySwift
import Alamofire

class SignUpVC: KeyboardViewController {
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var passwordCheckTxt: UITextField!
    @IBOutlet weak var createAccountBtn: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    
    let reachability = Reachability()
    var requestOngoing = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navImag = UIImage(named: "logoNav")
        self.navigationItem.titleView = UIImageView(image: navImag)
        try? reachability?.startNotifier() ?? print("No se pudo iniciar reachability")
        
    }
    
    
    @IBAction func createAccount(_ sender: UIButton) {
        
        if (nameTxt.text!.isEmpty) {
            self.displayAlert(title: "Nombre obligatorio", message: "Ingresa tu nombre")
        }else if (emailTxt.text!.isEmpty) {
            self.displayAlert(title: "Email obligatorio", message: "Ingresa tu correo electronico")
        }else if !(isValidEmail(emailTxt.text!)) {
            self.displayAlert(title:"Email válido",message: "Ingresa una dirección de correo válida")
        }else if (passwordTxt.text!.isEmpty) || passwordCheckTxt.text!.isEmpty {
            self.displayAlert(title: "Contraseña obligatorio", message: "Ingresa tu contraseña")
        }else if passwordTxt.text! != passwordCheckTxt.text! {
            self.displayAlert(title: "Contraseñas", message: "Las contraseñas no coinciden")
            passwordTxt.text = ""
            passwordCheckTxt.text = ""
        }else if(requestOngoing == false && (reachability?.isReachable)!){
            makeAccount(name:(nameTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,email:(emailTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines))!,password: (passwordTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines))!)
            
        }else if(!(reachability?.isReachable)!){
            self.displayAlert(title: "Internet", message: "Se necesita conexión a internet")
        }
        else{
            print("Error")
        }
        
    }
    
    func makeAccount(name:String,email:String,password:String){
        activity.isHidden = false
        activity.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        requestOngoing = true
        toggleFields()
        
        
        let parameters = ["email":email,"password":password,"name":name]
        Alamofire.request("https://tourneyserver.herokuapp.com/auth/signup/",method:.post,parameters:parameters).responseJSON { response in
            
            if response.response?.statusCode == 200 {
                if let json = response.result.value, let jsonArr = json as? [String:Any], let user = UserCreate(json: jsonArr){
                    if user.valid && user.created {
                        //TODO: Guardar datos y darle un mensaje al usuario
                        print(user.name!)
                    }else if(user.valid && !user.created){
                        self.displayAlert(title: "Error", message: user.message!)
                    }
                }
            }else{
                self.displayAlert(title: "Error", message: "Hubo un problema intentelo más tarde")
            }
            self.requestOngoing = false
            self.activity.isHidden = true
            self.activity.startAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.toggleFields()
        }
        
    }
    
    func monitorNetwork (){
        reachability?.whenUnreachable = { reachability in
            print("Not reachable")
        }
    }
    
    func toggleFields(){
        nameTxt.isEnabled = !nameTxt.isEnabled
        emailTxt.isEnabled = !emailTxt.isEnabled
        passwordTxt.isEnabled = !passwordTxt.isEnabled
        passwordCheckTxt.isEnabled = !passwordCheckTxt.isEnabled
        createAccountBtn.isEnabled = !createAccountBtn.isEnabled
    }
    
    
    func isValidEmail(_ email: String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = email as NSString
            let results = regex.matches(in: email, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
}
