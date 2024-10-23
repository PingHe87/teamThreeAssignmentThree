//
//  ModuleAViewController.swift
//  teamThreeAssignmentThree
//
//  Created by p h on 10/16/24.
//

import UIKit
import CoreMotion

class ModuleAViewController: UIViewController {
    
    var goalAchievedAlertShown = false
    
    let motionModel = MotionModel()
    var stepGoal: Int = 1000 // Default step goal
    var currentSteps: Int = 0 // Current step count
    var baselineSteps: Int = 0 // Baseline steps from start of the day
    var yesterdaySteps: Int = 0 // Yesterday's step count

    // MARK: - Outlets
    @IBOutlet weak var stepsTodayLabel: UILabel!
    @IBOutlet weak var stepsYesterdayLabel: UILabel!
    @IBOutlet weak var stepsGoalTextField: UITextField!
    @IBOutlet weak var stepsRemainingLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var stepsProgressLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate
        self.motionModel.delegate = self

        // Start monitoring activity and steps
        self.motionModel.startActivityMonitoring()

        // Get yesterday's steps
        self.motionModel.getYesterdaysSteps { steps in
            DispatchQueue.main.async {
                self.yesterdaySteps = Int(steps)
                self.stepsYesterdayLabel.text = "Yesterday's Steps: \(self.yesterdaySteps)"
                
                // Save yesterday's steps to UserDefaults
                UserDefaults.standard.set(self.yesterdaySteps, forKey: "yesterdaySteps")
            }
        }

        // Get today's steps from midnight
        self.motionModel.getTodaySteps { steps in
            DispatchQueue.main.async {
                self.baselineSteps = Int(steps)
                self.currentSteps = self.baselineSteps
                self.stepsTodayLabel.text = "Today's Steps: \(self.currentSteps)"
                self.updateStepsRemaining(currentSteps: self.currentSteps)

                // Start real-time step monitoring
                self.motionModel.startPedometerMonitoring()
            }
        }

        // Load user-defined step goal
        loadStepGoal()

        // Set initial default values for UILabels
        stepsTodayLabel.text = "Today's Steps: 0"
        stepsYesterdayLabel.text = "Yesterday's Steps: 0"
        stepsRemainingLabel.text = "Steps to Goal: \(stepGoal)"
        activityLabel.text = "Current Activity: Unknown"
        stepsProgressLabel.text = "0/\(stepGoal)"
        progressBar.progress = 0.0
        
        // Adjust progressBar height
        progressBar.transform = CGAffineTransform(scaleX: 1.0, y: 4.0)
            
        // Set progressBar color
        progressBar.progressTintColor = UIColor(red: 98/255, green: 86/255, blue: 202/255, alpha: 1.0)
        progressBar.trackTintColor = UIColor.systemGray
        
        // Add tap gesture to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    // MARK: - Dismiss Keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Step Goal Functionality
    @IBAction func saveStepGoal(_ sender: UIButton) {
        if let goalText = stepsGoalTextField.text, let goal = Int(goalText) {
            UserDefaults.standard.set(goal, forKey: "stepGoal")
            stepGoal = goal
            
            // Update UI after saving the step goal
            stepsRemainingLabel.text = "Steps to Goal: \(stepGoal - currentSteps)"
            stepsProgressLabel.text = "\(currentSteps)/\(stepGoal)"
            progressBar.setProgress(Float(currentSteps) / Float(stepGoal), animated: true)
        }
    }

    func loadStepGoal() {
        stepGoal = UserDefaults.standard.integer(forKey: "stepGoal")
        stepsGoalTextField.text = "\(stepGoal)"
    }

    // Update remaining steps and progress bar
    func updateStepsRemaining(currentSteps: Int) {
        var remainingSteps = stepGoal - currentSteps
        
        // Set remaining steps to 0 if less than 0
        if remainingSteps < 0 {
            remainingSteps = 0
        }
        
        stepsRemainingLabel.text = "Steps to Goal: \(remainingSteps)"
        
        let progress = Float(currentSteps) / Float(stepGoal)
        progressBar.setProgress(progress, animated: true)
        
        stepsProgressLabel.text = "\(currentSteps)/\(stepGoal)"
    }
}

// MARK: - MotionDelegate
extension ModuleAViewController: MotionDelegate {
    func activityUpdated(activity: CMMotionActivity) {
        var activityType = "Unknown"
        if activity.walking {
            activityType = "Walking"
        } else if activity.running {
            activityType = "Running"
        } else if activity.cycling {
            activityType = "Cycling"
        } else if activity.automotive {
            activityType = "Driving"
        } else if activity.stationary {
            activityType = "Stationary"
        }
        activityLabel.text = "Current Activity: \(activityType)"
    }

    func pedometerUpdated(pedData: CMPedometerData) {
        DispatchQueue.main.async {
            let realtimeSteps = pedData.numberOfSteps.intValue
            self.currentSteps = self.baselineSteps + realtimeSteps
            self.stepsTodayLabel.text = "Today's Steps: \(self.currentSteps)"
            
            self.updateStepsRemaining(currentSteps: self.currentSteps)

            if self.currentSteps >= self.stepGoal && !self.goalAchievedAlertShown {
                self.showGoalAchievedAlert()
                self.goalAchievedAlertShown = true
            } else if self.currentSteps < self.stepGoal {
                UserDefaults.standard.set(false, forKey: "stepGoalAchieved")
            }
        }
    }

    func showGoalAchievedAlert() {
        let alert = UIAlertController(title: "Congratulations!",
                                      message: "You've reached your step goal! Play a game with extra time!",
                                      preferredStyle: .alert)
        
        let playGameAction = UIAlertAction(title: "Play Game", style: .default) { (_) in
            self.performSegue(withIdentifier: "toModuleB", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(playGameAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    func accelerometerUpdated(x: Double, y: Double, z: Double) {
        // Method implementation required by protocol but not used in ModuleA
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toModuleB" {
            let destinationVC = segue.destination as! ModuleBViewController
            destinationVC.gameTime = 20 // Pass 20 seconds of game time
        }
    }
}

