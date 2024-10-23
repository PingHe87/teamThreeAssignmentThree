//
//  ModuleAViewController.swift
//  teamThreeAssignmentThree
//
//  Created by p h on 10/16/24.
//

import UIKit
import CoreMotion

class ModuleAViewController: UIViewController {
    
    // 添加一个变量来追踪对话框是否已经显示
    var goalAchievedAlertShown = false
    
    let motionModel = MotionModel()
    var stepGoal: Int = 1000 // 默认步数目标
    var currentSteps: Int = 0 // 保存当前步数
    var baselineSteps: Int = 0 // 新增基准步数变量
    var yesterdaySteps: Int = 0 // 保存昨天步数

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

        // 获取昨天的步数
        self.motionModel.getYesterdaysSteps { steps in
            DispatchQueue.main.async {
                self.yesterdaySteps = Int(steps)
                self.stepsYesterdayLabel.text = "Yesterday's Steps: \(self.yesterdaySteps)"
                
                // 保存昨天步数到 UserDefaults
                UserDefaults.standard.set(self.yesterdaySteps, forKey: "yesterdaySteps")
            }
        }

        // 获取今天从凌晨到现在的步数
        self.motionModel.getTodaySteps { steps in
            DispatchQueue.main.async {
                self.baselineSteps = Int(steps)
                self.currentSteps = self.baselineSteps
                self.stepsTodayLabel.text = "Today's Steps: \(self.currentSteps)"
                self.updateStepsRemaining(currentSteps: self.currentSteps)

                // 在获取今天的步数后，开始实时监控步数
                self.motionModel.startPedometerMonitoring()
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
        progressBar.progressTintColor = UIColor(red: 98/255, green: 86/255, blue: 202/255, alpha: 1.0)
        progressBar.trackTintColor = UIColor.systemGray
        
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
            activityType = "Stationary"
        }
        activityLabel.text = "Current Activity: \(activityType)"
    }

    func pedometerUpdated(pedData: CMPedometerData) {
        DispatchQueue.main.async {
            // 使用基准步数加上实时监控步数
            let realtimeSteps = pedData.numberOfSteps.intValue
            self.currentSteps = self.baselineSteps + realtimeSteps
            self.stepsTodayLabel.text = "Today's Steps: \(self.currentSteps)"
            
            // 更新进度条和剩余步数
            self.updateStepsRemaining(currentSteps: self.currentSteps)

            // 检查是否达到步数目标并弹出对话框
            if self.currentSteps >= self.stepGoal && !self.goalAchievedAlertShown {
                self.showGoalAchievedAlert()
                self.goalAchievedAlertShown = true
            } else if self.currentSteps < self.stepGoal {
                UserDefaults.standard.set(false, forKey: "stepGoalAchieved")
            }
        }
    }

    func showGoalAchievedAlert() {
        // 创建 UIAlertController
        let alert = UIAlertController(title: "Congratulations!",
                                      message: "You've reached your step goal! Play a game to relax now!",
                                      preferredStyle: .alert)
        
        // 添加 "Play Game" 按钮，点击后导航到 Module B
        let playGameAction = UIAlertAction(title: "Play Game", style: .default) { (_) in
            self.performSegue(withIdentifier: "toModuleB", sender: self)
        }
        
        // 添加 "Cancel" 按钮，点击后关闭对话框
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // 将按钮添加到 UIAlertController
        alert.addAction(playGameAction)
        alert.addAction(cancelAction)
        
        // 显示对话框
        self.present(alert, animated: true, completion: nil)
    }

    // 实现 accelerometerUpdated 方法，虽然在 ModuleA 中可能不需要用到它，但必须实现
    func accelerometerUpdated(x: Double, y: Double, z: Double) {
        // set it bull
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toModuleB" {  // 确保这个 identifier 和 Storyboard 中的 segue 一致
            let destinationVC = segue.destination as! ModuleBViewController
            destinationVC.gameTime = 20  // 传递20秒游戏时间
        }
    }
}

