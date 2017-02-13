//
//  TournamenteCreationVC.swift
//  TournamenteBrackets
//
//  Created by Joel Lara Quintana on 31/01/17.
//  Copyright © 2017 Joel Lara Quintana. All rights reserved.
//

import UIKit

class TournamentCreationVC: UIViewController {
    
    @IBOutlet weak var segmentedStage: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func unwindToCreation(sender: UIStoryboardSegue){
        
    }
    @IBAction func continueStage(_ sender: UIButton) {
        if segmentedStage.selectedSegmentIndex == 0{
            performSegue(withIdentifier: "toSimpleStageSegue", sender: sender)
        }else{
            performSegue(withIdentifier: "toTwoStageSegue", sender: sender)
        }
    }
}

