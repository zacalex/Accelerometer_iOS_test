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
    let Hz = 50.0
    var sum = 0
    let fileName = "test"
    let DocumentDirUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    var fileURL : URL! = nil
    var count = 0.0
    var tempSum = 0.0
    
    @IBOutlet weak var somez: UILabel!
    @IBOutlet weak var somex: UILabel!
    @IBOutlet weak var somey: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        fileURL = DocumentDirUrl.appendingPathComponent(fileName).appendingPathExtension("txt")
        print("file path : \(fileURL.path)")
        let writeString = "There is the Accelerometer\n"
        do{
            try writeString.write(to:fileURL,atomically: true,encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("fail to write to url")
            print(error)
        }
        setAcce()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func readfile() -> String{
        var readString = ""
        do{
            readString = try String(contentsOf:fileURL)
        } catch let error as NSError {
            print("fail to read file")
            print(error)
        }
//        print("Contents of the file\(readString)")
        return readString
    }
    func appendfile(svm : Double){
        let dataString = "\(svm)\n"
//        print("data to be append ", dataString)
        do{
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            fileHandle.seekToEndOfFile()
            fileHandle.write(dataString.data(using: .utf8)!)
            fileHandle.closeFile()
        } catch {
            print("Error writing to file \(error)")
        }
    }
    func setAcce() {
        motionManager.accelerometerUpdateInterval = 1.0/Hz
        motionManager.startAccelerometerUpdates(to : OperationQueue.current!){
            (data, error) in
            if let myData = data {
//                print(myData)
                var svm = myData.acceleration.x * myData.acceleration.x +
                    myData.acceleration.y * myData.acceleration.y +
                    myData.acceleration.z * myData.acceleration.z
                
                svm = sqrt(svm) - 1
                self.tempSum = self.tempSum + svm
                self.count = self.count + 1.0
                if(self.count > self.Hz){
                    self.count = 0;
                    self.appendfile(svm: svm)
                    svm = 0.0;
                    print(self.readfile())
                }
                self.view.reloadInputViews()
            }
        }
    }

}



