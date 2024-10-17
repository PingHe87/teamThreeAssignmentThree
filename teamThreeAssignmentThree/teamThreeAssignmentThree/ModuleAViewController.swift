//
//  ModuleAViewController.swift
//  teamThreeAssignmentThree
//
//  Created by p h on 10/16/24.
//

import UIKit
import CoreMotion

class ModuleAViewController: UIViewController {
    
    let motionModel = MotionModel()
    var stepGoal: Int = 1000 // 默认步数目标

    // MARK: - Outlets
    @IBOutlet weak var stepsTodayLabel: UILabel!
    @IBOutlet weak var stepsYesterdayLabel: UILabel!
    @IBOutlet weak var stepsGoalTextField: UITextField!
    @IBOutlet weak var stepsRemainingLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var stepsProgressLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!

    var currentSteps: Int = 0 // 用于保存当前步数

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置 delegate
        self.motionModel.delegate = self

        // 开始监控步数和活动状态
        self.motionModel.startActivityMonitoring()
        self.motionModel.startPedometerMonitoring()

        // 获取昨天的步数
        self.motionModel.getYesterdaysSteps { steps in
            DispatchQueue.main.async {
                self.stepsYesterdayLabel.text = "Yesterday's Steps: \(Int(steps))"
            }
        }

        // 加载用户设置的目标步数
        loadStepGoal()
    }

    // MARK: - 目标步数功能
    @IBAction func saveStepGoal(_ sender: UIButton) {
        if let goalText = stepsGoalTextField.text, let goal = Int(goalText) {
            UserDefaults.standard.set(goal, forKey: "stepGoal")
            stepGoal = goal
            updateStepsRemaining(currentSteps: currentSteps) // 使用当前步数更新剩余步数
        }
    }

    func loadStepGoal() {
        stepGoal = UserDefaults.standard.integer(forKey: "stepGoal")
        stepsGoalTextField.text = "\(stepGoal)"
    }

    // 更新剩余步数和进度条
    func updateStepsRemaining(currentSteps: Int) {
        let remainingSteps = stepGoal - currentSteps
        stepsRemainingLabel.text = "Steps to Goal: \(remainingSteps)"
        
        // 更新进度条
        let progress = Float(currentSteps) / Float(stepGoal)
        progressBar.setProgress(progress, animated: true)
        
        // 显示步数进度
        stepsProgressLabel.text = "\(currentSteps)/\(stepGoal)"
    }
}

// MARK: - MotionDelegate
extension ModuleAViewController: MotionDelegate {
    func activityUpdated(activity: CMMotionActivity) {
        var activityType = "Unknown"
        if activity.walking {
            activityType = "🚶Walking"
        } else if activity.running {
            activityType = "🏃Running"
        } else if activity.cycling {
            activityType = "🚴Cycling"
        } else if activity.automotive {
            activityType = "🚘Driving"
        } else if activity.stationary {
            activityType = "Stationary"
        }
        activityLabel.text = "Current Activity: \(activityType)"
    }

    func pedometerUpdated(pedData: CMPedometerData) {
        DispatchQueue.main.async {
            self.currentSteps = pedData.numberOfSteps.intValue // 保存当前步数
            self.stepsTodayLabel.text = "Today's Steps: \(self.currentSteps)"
            
            // 更新进度条和剩余步数
            self.updateStepsRemaining(currentSteps: self.currentSteps)
        }
    }
}
