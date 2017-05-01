//
//  FormatVC.swift
//  TournamenteBrackets
//
//  Created by Joel Lara Quintana on 13/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
import Alamofire
import Gloss
import ReachabilitySwift




class SingleStageVC: KeyboardViewController {
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var formatoPV: UIPickerView!
    
    let reachability = Reachability()
    var tournamentMaster:TournamentMaster!
    var tournament = Tournament()
    
    let tipoTorneo = ["Eliminacion directa", "Doble eliminacion","Todos contra todos"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try? reachability?.startNotifier() ?? print("No se pudo iniciar reachability")
        self.monitorNetwork()
    }
    
    private func monitorNetwork (){
        reachability?.whenUnreachable = { reachability in
            print("Not reachable")
        }
    }
    
    @IBAction func toBrackets(_ sender: UIButton) {

        self.tournamentMaster.groupStage = self.tournament
        let params = self.tournamentMaster.toJSON()
        if !(reachability?.isReachable)! {
            self.displayAlert(title: "Red", message: "Se necesita una conexión de red para poder crear el torneo")
        }else{
            if params != nil {
                self.activity.isHidden = false
                self.activity.startAnimating()
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                Alamofire.request("https://tourneyserver.herokuapp.com/tournament/", method: .post, parameters: params,encoding:JSONEncoding.default).responseJSON{ response in
                    self.activity.isHidden = true
                    self.activity.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if response.response?.statusCode == 200 {
                        if let json = response.result.value, let jsonArr = json as? [String:Any],let res = createNewTournament(json:jsonArr){
                            if res.valid && res.created {
                                if let navigator = self.navigationController {
                                    navigator.popToRootViewController(animated: false)
                                }else{
                                    print("No navigator")
                                }
                            }else{
                                self.displayAlert(title: "Error", message: "Tuvimos un error interno, inténtalo más tarde")
                            }
                        }else{
                            print("couldn't parse")
                        }
                    }else{
                        self.displayAlert(title: "Error", message: "Tuvimos un error interno, inténtalo más tarde")
                    }
            }
        }else{
                self.displayAlert(title: "Error", message: "Tuvimos un error interno, inténtalo más tarde")
            }
        }
    }
}

extension SingleStageVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView:	UIPickerView)->Int {
        return 1
    }
    func pickerView(_ pickerView:UIPickerView,numberOfRowsInComponent component:Int)->Int{
        return tipoTorneo.count
    }
    func pickerView(_ pickerView:UIPickerView,titleForRow row:	Int, forComponent component:Int)->String?{
        return tipoTorneo[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            self.tournament.tournament_type = Tournament.tournament_format.singleElimination
        case 1:
            self.tournament.tournament_type = Tournament.tournament_format.doubleElimination
        case 2:
            self.tournament.tournament_type = Tournament.tournament_format.roundRobin
        default:
            break
        }
    }
}
