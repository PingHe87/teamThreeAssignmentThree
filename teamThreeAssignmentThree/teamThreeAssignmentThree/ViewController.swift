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
        // 从 UserDefaults 获取昨天步数和目标步数
           let yesterdaySteps = UserDefaults.standard.integer(forKey: "yesterdaySteps")
           let stepGoal = UserDefaults.standard.integer(forKey: "stepGoal")
           
           // 判断昨天步数是否达到目标
           if yesterdaySteps < stepGoal {
               // 显示一个警告，提示用户还没有达到目标步数
               let alert = UIAlertController(title: "Keep Going!", message: "You need to reach your step goal yesterday to unlock this game.", preferredStyle: .alert)
               let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
               alert.addAction(okAction)
               self.present(alert, animated: true, completion: nil)
           }
           // 如果昨天步数达到目标，则不需要手动调用 segue，Storyboard 中的 segue 会自动触发
    }
    
}

