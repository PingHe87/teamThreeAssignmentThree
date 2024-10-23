//
//  ViewController.swift
//  teamThreeAssignmentThree
//
//  Created by p h on 10/16/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func easyFunButtonTapped(_ sender: UIButton) {
        // Get yesterday's steps and step goal from UserDefaults
        let yesterdaySteps = UserDefaults.standard.integer(forKey: "yesterdaySteps")
        let stepGoal = UserDefaults.standard.integer(forKey: "stepGoal")
        
        // Check if yesterday's steps meet the goal
        if yesterdaySteps < stepGoal {
            // Show an alert if the goal was not met
            let alert = UIAlertController(title: "Keep Going!", message: "You need to reach your step goal yesterday to unlock this game.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        // If yesterday's steps meet the goal, Storyboard segue will be triggered automatically
    }
    
}

