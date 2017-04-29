//
//  TournamentListingVC.swift
//  MyBrackets
//
//  Created by Joel Lara Quintana on 20/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
class TournamentListingVC:KeyboardViewController {
    var arrSingle = [Tournament]()
    var arrTwo = [Tournament]()
    let prefs = UserDefaults.standard
    
    @IBOutlet var tournamentsTV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        if let (arr1, arr2) = Tournament.obtenerTorneos() {
            arrSingle = arr1
            arrTwo = arr2
        }
        */
        setupEmptyView()
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
        tournamentsTV.backgroundView = EmptyStateV()
    }
}



extension TournamentListingVC:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return arrSingle.count
        case 1:
            return arrTwo.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        if indexPath.section == 0 {
            celda.textLabel?.text = arrSingle[indexPath.row].name!
        }else{
            celda.textLabel?.text = arrTwo[indexPath.row].name!
        }
        return celda
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
