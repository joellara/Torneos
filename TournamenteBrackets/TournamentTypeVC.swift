//
//  TournamentTypeVC.swift
//  TournamenteBrackets
//
//  Created by Joel Lara Quintana on 13/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
class TournamentTypeVC: UIViewController,UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var participantsTV: UITableView!
    @IBOutlet weak var stageSC: UISegmentedControl!
    @IBOutlet weak var participantName: UITextField!
    
    var arrParticipants = [String]()
    override func viewDidLoad() {
        self.hideKeyboard()
        participantsTV.layer.borderColor = UIColor.red.cgColor
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrParticipants.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        celda.textLabel?.text = arrParticipants[indexPath.row]
        return celda
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Borrar"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            arrParticipants.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addPerson()
        return true
    }
    @IBAction func addPerson() {
        if let name = participantName.text {
            if !name.isEmpty {
                arrParticipants.append(name)
                participantsTV.reloadData()
                participantName.text = ""
                participantsTV.layer.borderWidth = 0.0
            }
        }
    }
    
    @IBAction func continueStage(_ sender: UIButton) {
        if arrParticipants.count > 0 {
            if stageSC.selectedSegmentIndex == 0 {
                performSegue(withIdentifier: "toSingleStageSegue", sender: nil)
            }else{
                performSegue(withIdentifier: "toTwoStageSegue", sender: nil)
            }
        }else{
            participantsTV.layer.borderWidth = 1.0
        }
    }
}
