//
//  bracketsVC.swift
//  MyBrackets
//
//  Created by Joel Lara Quintana on 20/03/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit
class BracketsVC: UIViewController {
    var tournament:Tournament!
    override func viewDidLoad() {
        super.viewDidLoad()
        if tournament.save() {
            print("Se guardo torneo")
        }else{
            print("No se pudo guardar torneo")
        }
    }
}
