//
//  SearchVC.swift
//  MyBrackets
//
//  Created by Joel Lara Quintana on 27/04/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
import ReachabilitySwift
import Alamofire
import Gloss


class SearchVC: KeyboardViewController {

    @IBOutlet weak var tournamentID: UITextField!
    let reachability = Reachability()
    let prefs = UserDefaults.standard
    
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navImag = UIImage(named: "logoNav")
        self.navigationItem.titleView = UIImageView(image: navImag)
        try? reachability?.startNotifier() ?? print("No se pudo iniciar reachability")
        self.monitorNetwork()
    }
    private func monitorNetwork(){
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchTournament(_ sender: UIButton) {
        if !(reachability?.isReachable)! {
            self.displayAlert(title: "Red", message: "Se necesita una conexión de red para poder crear el torneo")
        }else{
            if (self.tournamentID.text?.isEmpty)! {
                self.displayAlert(title: "Error", message: "Ingresa un id")
            }else{
                self.searchBtn.isEnabled = false
                self.activity.startAnimating()
                self.activity.isHidden = false
                
                var stringUrl = "https://tourneyserver.herokuapp.com/tournament/master/".appending(self.tournamentID.text!)
                stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                Alamofire.request(stringUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                    
                    self.searchBtn.isEnabled = true
                    self.activity.stopAnimating()
                    self.activity.isHidden = true
                    
                    if response.response?.statusCode == 200 {
                        if let json = response.result.value, let jsonArr = json as? JSON, let res = rSearchTournament(json: jsonArr) {
                            if res.valid && res.found {
                                var storedTournaments = self.prefs.object(forKey: "torneos") as? [[String:String]] ?? [[String:String]]()
                                var found = false
                                for tournament in storedTournaments {
                                    if tournament["id"] == res.tournament!._id {
                                        found = true
                                    }
                                }
                                if !found {
                                    let new = ["name":res.tournament!.name,"id":res.tournament!._id!]
                                    storedTournaments.append(new)
                                    self.prefs.set(storedTournaments, forKey: "torneos")
                                    self.prefs.synchronize()
                                    self.displayAlert(title: ":)", message: "Se ha agregado el torneo")
                                    let searchAlert = UIAlertController(title: ":)", message: "Se ha agregado el torneo", preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "OK" , style: .default){ action in
                                        if let navigator = self.navigationController {
                                            navigator.popToRootViewController(animated: true)
                                        }else{
                                            print("No navigator")
                                        }
                                        
                                    }
                                    searchAlert.addAction(okAction)
                                    self.present(searchAlert, animated: true, completion: nil)
                                }else{
                                    self.displayAlert(title: ":)", message: "Ya está agregado el torneo")
                                }
                                
                            }else{
                                self.displayAlert(title: ":(", message: res.message!)
                            }
                        }else{
                            self.displayAlert(title: "Error", message: "Tuvimos un error interno, inténtalo de nuevo más tarde")
                        }
                    }else{
                        self.displayAlert(title: "Error", message: "Tuvimos un error interno, inténtalo de nuevo más tarde")
                    }
                }
            }
        }
    }
    
}
