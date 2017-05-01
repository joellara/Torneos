//
//  TwoStageVC.swift
//  TournamenteBrackets
//
//  Created by Joel Lara Quintana on 14/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
import ReachabilitySwift
import Alamofire
import Gloss

class TwoStageVC: KeyboardViewController{
    let tipoTorneo = ["Eliminacion directa", "Doble eliminacion","Todos contra todos"]
    
    @IBOutlet weak var scrollView: UIScrollView!
    var tournamentMaster:TournamentMaster!
    var groupStage = Tournament()
    var finalStage = Tournament()
    let reachability = Reachability()
    var keyboard = false
    
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        try? reachability?.startNotifier() ?? print("No se pudo iniciar reachability")
    }


    
    @IBAction func toBrackets(_ sender: UIButton) {
        self.tournamentMaster.groupStage = self.groupStage
        self.tournamentMaster.finalStage = self.finalStage
        let params = self.tournamentMaster.toJSON()
        if !(reachability?.isReachable)! {
            self.displayAlert(title: "Red", message: "Se necesita una conexión de red para poder crear el torneo")
        }else{
            if params != nil {
                self.activity.isHidden = false
                self.createBtn.isEnabled = false
                self.activity.startAnimating()
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                Alamofire.request("https://tourneyserver.herokuapp.com/tournament/", method: .post, parameters: params,encoding:JSONEncoding.default).responseJSON{ response in
                    self.activity.isHidden = true
                    self.createBtn.isEnabled = true
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
extension TwoStageVC: UIPickerViewDataSource, UIPickerViewDelegate  {
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
        if pickerView.tag == 0 {
            switch row {
            case 0:
                self.groupStage.tournament_type = Tournament.tournament_format.singleElimination
            case 1:
                self.groupStage.tournament_type = Tournament.tournament_format.doubleElimination
            case 2:
                self.groupStage.tournament_type = Tournament.tournament_format.roundRobin            default:
                break
            }
        }else{
            switch row {
            case 0:
                self.finalStage.tournament_type = Tournament.tournament_format.singleElimination
            case 1:
                self.finalStage.tournament_type = Tournament.tournament_format.doubleElimination
            case 2:
                self.finalStage.tournament_type = Tournament.tournament_format.roundRobin
            default:
                break
            }
        }
    }
}
