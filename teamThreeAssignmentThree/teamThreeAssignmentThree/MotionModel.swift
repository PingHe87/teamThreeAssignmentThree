//
//  MotionModel.swift
//  teamThreeAssignmentThree
//
//  Created by p h on 10/16/24.
//

import Foundation
import CoreMotion

// setup a protocol for the ViewController to be delegate for
protocol MotionDelegate {
    // Define delegate functions
    func activityUpdated(activity:CMMotionActivity)
    func pedometerUpdated(pedData:CMPedometerData)
    func accelerometerUpdated(x: Double, y: Double, z: Double)  //add new accelerater
}

class MotionModel{
    
    // MARK: =====Class Variables=====
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    private let motionManager = CMMotionManager()
    var delegate:MotionDelegate? = nil
    
    // MARK: =====Motion Methods=====
    func startActivityMonitoring(){
        // is activity is available
        if CMMotionActivityManager.isActivityAvailable(){
            // update from this queue (should we use the MAIN queue here??.... )
            self.activityManager.startActivityUpdates(to: OperationQueue.main)
            {(activity:CMMotionActivity?)->Void in
                // unwrap the activity and send to delegate
                // using the real time pedometer might influences how often we get activity updates...
                // so these updates can come through less often than we may want
                if let unwrappedActivity = activity,
                   let delegate = self.delegate {
                    // Print if we are walking or running
                    print("%@",unwrappedActivity.description)
                    
                    // Call delegate function
                    delegate.activityUpdated(activity: unwrappedActivity)
                    
                }
            }
        }
        
    }
    
//    func startPedometerMonitoring(){
//        // check if pedometer is okay to use
//        if CMPedometer.isStepCountingAvailable(){
//            // start updating the pedometer from the current date and time
//            pedometer.startUpdates(from: Date())
//            {(pedData:CMPedometerData?, error:Error?)->Void in
//                
//                // if no errors, update the delegate
//                if let unwrappedPedData = pedData,
//                   let delegate = self.delegate {
//                    
//                    delegate.pedometerUpdated(pedData:unwrappedPedData)
//                }
//
//            }
//        }
//    }
    
    // 实时监控步数
    func startPedometerMonitoring() {
            if CMPedometer.isStepCountingAvailable() {
                pedometer.startUpdates(from: Date()) { (pedData, error) in
                    if let unwrappedPedData = pedData, let delegate = self.delegate {
                        delegate.pedometerUpdated(pedData: unwrappedPedData)
                    }
                }
            }
        }
    
    //Accelerometer Monitor
        func startAccelerometerMonitoring() {
            if motionManager.isAccelerometerAvailable {
                motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
                    if let accelerometerData = data, let delegate = self.delegate {
                        delegate.accelerometerUpdated(x: accelerometerData.acceleration.x, y: accelerometerData.acceleration.y, z: accelerometerData.acceleration.z)
                    }
                }
            }
        }
    
    func stopMonitoring() {
            activityManager.stopActivityUpdates()
            pedometer.stopUpdates()
            motionManager.stopAccelerometerUpdates()
        }
        
    //n
    // 获取今天的步数，从凌晨到当前时间
        func getTodaySteps(completion: @escaping (Double) -> Void) {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date()) // 获取今天凌晨的时间

            if CMPedometer.isStepCountingAvailable() {
                pedometer.queryPedometerData(from: startOfDay, to: Date()) { (pedData, error) in
                    if let pedData = pedData {
                        completion(pedData.numberOfSteps.doubleValue)
                    } else {
                        print("Error retrieving today's steps: \(String(describing: error))")
                        completion(0)
                    }
                }
            }
        }
    
    
    // ASS3: Get Yesterday Steps
    func getYesterdaysSteps(completion: @escaping (Double) -> Void) {
            let calendar = Calendar.current
            let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))!
            let endOfYesterday = calendar.startOfDay(for: Date())

            if CMPedometer.isStepCountingAvailable() {
                pedometer.queryPedometerData(from: startOfYesterday, to: endOfYesterday) { (pedData, error) in
                    if let pedData = pedData {
                        completion(pedData.numberOfSteps.doubleValue)
                    } else {
                        print("Error retrieving yesterday's steps: \(String(describing: error))")
                        completion(0)
                    }
                }
            }
        }
    
    
}
