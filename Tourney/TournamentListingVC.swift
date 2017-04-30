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


class TournamentListingVC:KeyboardViewController {
    var arrSingle = [TournamentMaster]()
    var arrTwo = [TournamentMaster]()
    let prefs = UserDefaults.standard
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet var tournamentsTV: UITableView!
    
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var profileBtn: UIBarButtonItem!
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupEmptyView()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: UIControlEvents.valueChanged)
        self.tournamentsTV?.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadTournaments()
    }
    func refresh(_ sender:AnyObject){
        self.loadTournaments()
    }
    func loadTournaments(){
        if let api = prefs.string(forKey: "api_key") {
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
                    if let json = response.result.value, let jsonArr = json as? [String:Any], let tournamentArr = jsonArr["tournaments"] as? [[String:Any]], let tournaments = [TournamentMaster].from(jsonArray: tournamentArr){
                        for tournament in tournaments {
                            if tournament.tournamentType == .singleStage {
                                self.arrSingle.append(tournament)
                            }else{
                                self.arrTwo.append(tournament)
                            }
                        }
                        self.tournamentsTV.reloadData()
                    }else{
                        print("couldn't parse")
                    }
                }
            }
        }else{
            self.arrSingle = [TournamentMaster]()
            self.arrTwo = [TournamentMaster]()
            self.tournamentsTV.reloadData()
        }
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
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
        tournamentsTV.backgroundView = EmptyStateV(frame:self.view.frame    )
    }
}



extension TournamentListingVC:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch section {
        case 0:
            count =  arrSingle.count
        case 1:
            count =  arrTwo.count
        default:
            break
        }
        if count == 0 {
            tableView.separatorStyle = .none
            tableView.backgroundView!.isHidden = false
        }else{
            tableView.separatorStyle = .singleLine
            tableView.backgroundView!.isHidden = true
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        if indexPath.section == 0 {
            celda.textLabel?.text = arrSingle[indexPath.row].name
        }else{
            celda.textLabel?.text = arrTwo[indexPath.row].name
        }
        return celda
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if arrSingle.count == 0 {
                return nil
            }
        }else{
            if arrTwo.count == 0 {
                return nil
            }
        }
        switch section {
        case 0:
            return "Single Stage"
        case 1:
            return "Two Stage"
        default:
            return ""
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let deleteAlert = UIAlertController(title: "Borrar", message: "¿Está seguro que desea borrar este torneo?", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "No" , style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Borrar", style: .destructive, handler: { action in
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
                                self.loadTournaments()
                            }
                        }else{
                            self.displayAlert(title: "Error", message: "Tuvimos un error interno, inténtalo de nuevo más tarde")
                        }
                    }else{
                         self.displayAlert(title: "Error", message: "Tuvimos un error interno, inténtalo de nuevo más tarde")
                    }
                }
            })
            deleteAlert.addAction(closeAction)
            deleteAlert.addAction(deleteAction)
            present(deleteAlert, animated: true, completion: nil)
            
        }
    }
}
