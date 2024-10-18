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
    var currentSteps: Int = 0 // 保存当前步数

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

        // 设置 UILabel 的初始默认值
        stepsTodayLabel.text = "Today's Steps: 0"
        stepsYesterdayLabel.text = "Yesterday's Steps: 0"
        stepsRemainingLabel.text = "Steps to Goal: \(stepGoal)"
        activityLabel.text = "Current Activity: Unknown"
        stepsProgressLabel.text = "0/\(stepGoal)"
        progressBar.progress = 0.0
        
        // 调整 progressBar 的高度，使其更粗
        progressBar.transform = CGAffineTransform(scaleX: 1.0, y: 4.0)
            
        // 设置进度条的颜色
        progressBar.progressTintColor = UIColor.systemMint
        progressBar.trackTintColor = UIColor.systemGray4

        // 添加点击手势识别器，点击空白处关闭键盘
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }


    // MARK: - 关闭键盘
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - 目标步数功能
    @IBAction func saveStepGoal(_ sender: UIButton) {
        if let goalText = stepsGoalTextField.text, let goal = Int(goalText) {
            UserDefaults.standard.set(goal, forKey: "stepGoal")
            stepGoal = goal
            
            // 确保在保存目标步数后更新所有相关的 UI
            stepsRemainingLabel.text = "Steps to Goal: \(stepGoal - currentSteps)"
            stepsProgressLabel.text = "\(currentSteps)/\(stepGoal)"
            progressBar.setProgress(Float(currentSteps) / Float(stepGoal), animated: true)
        }
    }


    func loadStepGoal() {
        stepGoal = UserDefaults.standard.integer(forKey: "stepGoal")
        stepsGoalTextField.text = "\(stepGoal)"
    }

    // 更新剩余步数和进度条
    func updateStepsRemaining(currentSteps: Int) {
        // 计算剩余步数
        var remainingSteps = stepGoal - currentSteps
        
        // 如果剩余步数小于 0，则设置为 0
        if remainingSteps < 0 {
            remainingSteps = 0
        }
        
        // 更新剩余步数的显示
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
            activityType = "Walking"
        } else if activity.running {
            activityType = "Running"
        } else if activity.cycling {
            activityType = "Cycling"
        } else if activity.automotive {
            activityType = "Driving"
        } else if activity.stationary {
            activityType = "Still"
        }
        activityLabel.text = "Current Activity: \(activityType)"
    }

    func pedometerUpdated(pedData: CMPedometerData) {
        DispatchQueue.main.async {
            self.currentSteps = pedData.numberOfSteps.intValue // 保存当前步数到变量
            self.stepsTodayLabel.text = "Today's Steps: \(self.currentSteps)"
            
            // 更新进度条和剩余步数
            self.updateStepsRemaining(currentSteps: self.currentSteps)
        }
    }
    // 实现 accelerometerUpdated 方法，虽然在 ModuleA 中可能不需要用到它，但必须实现
        func accelerometerUpdated(x: Double, y: Double, z: Double) {
            // set it bull
        }
}

