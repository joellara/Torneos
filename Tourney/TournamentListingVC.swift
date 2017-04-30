//
//  TournamentListingVC.swift
//  MyBrackets
//
//  Created by Joel Lara Quintana on 20/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
import Alamofire

class TournamentListingVC:KeyboardViewController {
    var arrSingle = [TournamentMaster]()
    var arrTwo = [TournamentMaster]()
    let prefs = UserDefaults.standard
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet var tournamentsTV: UITableView!
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
    private func loadTournaments(){
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
                            self.tournamentsTV.reloadData()
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
}
