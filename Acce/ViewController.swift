//
//  ViewController.swift
//  Acce
//
//  Created by Qinjia Huang on 11/27/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit
import CoreMotion
class ViewController: UIViewController {
    var motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to : OperationQueue.current!){
            (data, error) in
            if let myData = data {
                print(myData)
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

