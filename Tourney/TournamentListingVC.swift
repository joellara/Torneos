//
//  TournamentListingVC.swift
//  MyBrackets
//
//  Created by Joel Lara Quintana on 20/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
import Alamofire
import Gloss
import ReachabilitySwift

struct deleteTournament : Decodable {
    var valid:Bool
    var deleted:Bool
    
    init?(json: JSON) {
        guard let valid:Bool = "valid" <~~ json,
            let deleted:Bool = "deleted" <~~ json else {
                return nil
        }
        self.valid = valid
        self.deleted = deleted
    }
}

struct stateTournament:Decodable{
    var valid:Bool
    var found:Bool
    var message:String?
    var tournament:Tournament?
    init?(json: JSON) {
        guard let valid:Bool = "valid" <~~ json,
            let found:Bool = "found" <~~ json else {
                return nil
        }
        self.valid = valid
        self.found = found
        if self.found {
            guard let tourn:Tournament = "tournament" <~~ json else { return nil }
            self.tournament = tourn
        }
        self.message = "message" <~~ json
    }
}


class TournamentListingVC:KeyboardViewController {
    var arrSingle = [TournamentMaster]()
    var arrTwo = [TournamentMaster]()
    var arrGuardados = [[String:String]]()
    
    let prefs = UserDefaults.standard
    var refreshControl = UIRefreshControl()
    let reachability = Reachability()
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet var tournamentsTV: UITableView!
    
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var profileBtn: UIBarButtonItem!
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: UIControlEvents.valueChanged)
        self.tournamentsTV?.addSubview(refreshControl)
        try? reachability?.startNotifier()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupEmptyView()
        self.loadTournaments()

    }
    
    func refresh(_ sender:AnyObject){
        if (reachability?.isReachable)! {
            self.loadTournaments()
        }else{
            self.displayAlert(title: "Red", message: "Se necesita una conexión a internet")
        }
    }
    func loadTournaments(){
        if let tournaments = self.prefs.object(forKey: "torneos") as? [[String:String]] {
            self.arrGuardados = tournaments
        }
        if let api = prefs.string(forKey: "api_key"), (reachability?.isReachable)! {
            let params = ["api_key":api]
            self.activity.isHidden = false
            self.activity.startAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            Alamofire.request("https://tourneyserver.herokuapp.com/tournament/", method: .get, parameters: params).responseJSON { response in
                self.activity.isHidden = true
                self.activity.stopAnimating()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if response.response?.statusCode == 200 {
                    self.arrSingle = [TournamentMaster]()
                    self.arrTwo = [TournamentMaster]()
                    if let json = response.result.value,
                        let jsonArr = json as? [String:Any],
                        let tournamentArr = jsonArr["tournaments"] as? [JSON],
                        let tournaments = [TournamentMaster].from(jsonArray: tournamentArr){
                        for tournament in tournaments {
                            if tournament.tournamentType == .singleStage {
                                self.arrSingle.append(tournament)
                            }else{
                                self.arrTwo.append(tournament)
                            }
                        }
                        self.tournamentsTV.reloadData()
                        if self.refreshControl.isRefreshing {
                            self.refreshControl.endRefreshing()
                        }
                    }else{
                        print("couldn't parse")
                    }
                }
            }
        }else{
            self.arrSingle = [TournamentMaster]()
            self.arrTwo = [TournamentMaster]()
            self.tournamentsTV.reloadData()
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }

    }
    
    @IBAction func addNewTournament(_ sender: UIBarButtonItem) {
        if (prefs.string(forKey: "api_key") != nil) {
            performSegue(withIdentifier: "toGameCreation", sender: nil)
        }else{
            let signInAlert = UIAlertController(title: "Inicia sesión", message: "Inicia sesión para agregar nuevos torneos", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "Cerrar" , style: .cancel,handler:nil)
            let signInAction = UIAlertAction(title: "Inicia sesión", style: .default){ alert in
                self.performSegue(withIdentifier: "signInFromGame", sender: nil)
            }
            signInAlert.addAction(closeAction)
            signInAlert.addAction(signInAction)
            present(signInAlert, animated: true, completion: nil)
        }
    }
    
    func setupEmptyView(){
        let newView = EmptyStateV(frame:self.view.frame)
        if (prefs.string(forKey: "api_key") == nil) {
            newView.label.text = "Inicia sesión."
        }else{
            newView.label.text = "No hay torneos."
        }
        tournamentsTV.backgroundView = newView
        tournamentsTV.backgroundView?.isHidden = true
    }
}



extension TournamentListingVC:UITableViewDelegate,UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch section {
        case 0:
            count =  arrSingle.count
        case 1:
            count =  arrTwo.count
        case 2:
            count = arrGuardados.count
        default:
            break
        }
        if arrSingle.count == 0 && arrTwo.count == 0 && arrGuardados.count == 0{
            tableView.separatorStyle = .none
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView?.isHidden = true
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        if indexPath.section == 0 {
            celda.textLabel?.text = arrSingle[indexPath.row].name
        }else if indexPath.section == 1{
            celda.textLabel?.text = arrTwo[indexPath.row].name
        }else{
            celda.textLabel?.text = arrGuardados[indexPath.row]["name"]
        }
        return celda
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if arrSingle.count == 0 {
                return nil
            }
        }else if section == 1{
            if arrTwo.count == 0 {
                return nil
            }
        }else{
            if arrGuardados.count == 0 {
                return nil
            }
        }
        switch section {
        case 0:
            return "Una etapa"
        case 1:
            return "Dos etapas"
        case 2:
            return "Torneos guardados"
        default:
            return ""
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            let deleteAlert = UIAlertController(title: "Borrar", message: "¿Está seguro que desea borrar este torneo?", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "No" , style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Borrar", style: .destructive, handler: { action in
                if indexPath.section == 2 {
                    if var storedTournaments = self.prefs.object(forKey: "torneos") as? [[String:String]] {
                        for i in 0 ..< storedTournaments.count {
                            if storedTournaments[i]["id"] == self.arrGuardados[indexPath.row]["id"] {
                                storedTournaments.remove(at: i)
                                break
                            }
                        }
                        self.prefs.set(storedTournaments, forKey: "torneos")
                        self.prefs.synchronize()
                        self.arrGuardados = storedTournaments
                        self.tournamentsTV.reloadData()
                    }
                }else{
                    self.addBtn.isEnabled = false
                    self.searchBtn.isEnabled = false
                    self.profileBtn.isEnabled = false
                    self.activity.isHidden = false
                    self.activity.startAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    let api = self.prefs.string(forKey: "api_key")!
                    let tournament:TournamentMaster
                    if indexPath.section == 0 {
                        tournament = self.arrSingle[indexPath.row]
                    }else{
                        tournament = self.arrTwo[indexPath.row]
                    }
                    let params = ["api_key":api]
                    var stringUrl = "https://tourneyserver.herokuapp.com/tournament/".appending(tournament._id!)
                    stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    Alamofire.request(stringUrl, method: .delete, parameters: params ,encoding:JSONEncoding.default).responseJSON{ response in
                        self.addBtn.isEnabled = true
                        self.searchBtn.isEnabled = true
                        self.profileBtn.isEnabled = true
                        self.activity.isHidden = true
                        self.activity.stopAnimating()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if response.response?.statusCode == 200 {
                            if let json = response.result.value, let jsonArr = json as? JSON, let res = deleteTournament(json: jsonArr) {
                                if res.valid && res.deleted {
                                    print("Se borro")
                                }
                            }else{
                                self.displayAlert(title: "Error", message: "Tuvimos un error interno, inténtalo de nuevo más tarde")
                            }
                        }else{
                            self.displayAlert(title: "Error", message: "Tuvimos un error interno, inténtalo de nuevo más tarde")
                        }
                        self.loadTournaments()
                    }
                }
            })
            deleteAlert.addAction(closeAction)
            deleteAlert.addAction(deleteAction)
            present(deleteAlert, animated: true, completion: nil)
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var id:String?
        switch indexPath.section {
        case 0:
            id = arrSingle[indexPath.row].groupStageID!
        case 1:
            id = arrTwo[indexPath.row].groupStageID!
        case 2:
            id = arrGuardados[indexPath.row]["group_id"]
        default:
            break
        }
        if id != nil {
            var stringUrl = "https://tourneyserver.herokuapp.com/tournament/".appending(id!)
            stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            Alamofire.request(stringUrl, method:.get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                if response.response?.statusCode == 200 {
                    if let json = response.result.value, let jsonArr = json as? JSON, let res = stateTournament(json: jsonArr) {
                        if res.valid && res.found {
//                            print(res.tournament!)
                        }else{
                            print("Should happen, but not found")
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
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Borrar"
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        var id = ""
        if indexPath.section == 0 {
            id = arrSingle[indexPath.row]._id!
        }else{
            id = arrTwo[indexPath.row]._id!
        }
        let idAlert = UIAlertController(title: "ID para búsqueda", message: "Utiliza este ID para darselo a tus amigos y que puedan ver el progreso.\n".appending(id), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK" , style: .default, handler: nil)
        let copyAction = UIAlertAction(title: "Copiar", style: .default, handler: {action in
            UIPasteboard.general.string = id
        })
        idAlert.addAction(okAction)
        idAlert.addAction(copyAction)
        present(idAlert, animated: true, completion: nil)
    }
}
