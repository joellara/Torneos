//
//  TournamentListingVC.swift
//  MyBrackets
//
//  Created by Joel Lara Quintana on 20/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
class TournamentListingVC:UIViewController {
    var arrSingle = [Tournament]()
    var arrTwo = [Tournament]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let (arr1, arr2) = Tournament.obtenerTorneos() {
            arrSingle = arr1
            arrTwo = arr2
        }
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
