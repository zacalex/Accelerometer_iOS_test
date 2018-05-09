//
//  ViewController.swift
//  Acce
//
//  Created by Qinjia Huang on 11/27/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit
import CoreMotion
import Alamofire
import CoreLocation
import MessageUI

class ViewController: UIViewController, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate {
    var motionManager = CMMotionManager()
    var Hz = 60.0
    var sum = 0
    var fileName = "acce_data"
    let DocumentDirUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    var fileURL : URL! = nil
    var count = 0.0
    var tempSum = 0.0
    var basicUrl = "http://10.120.64.78:8888/TEST.php"
    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var countLine = 0
    //上一次的坐标
    var lastLocation: CLLocation!
    //总共移动的距离（实际距离）
    
    let calendar = Calendar.current
    var buffer = ""
    var uploaded = false
    var appended = false
    var input = "50"

    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var setRate: UILabel!
    @IBOutlet weak var startAcc: UIButton!
    @IBOutlet weak var stopAcc: UIButton!
    @IBOutlet weak var emailData: UIButton!
    @IBOutlet weak var resetfile: UIButton!
    
    @IBOutlet weak var sampleRate: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fileURL = DocumentDirUrl.appendingPathComponent(fileName).appendingPathExtension("txt")
        print("file path : \(fileURL.path)")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path){
            print("File exist")
        } else {
            print("File not exist")
            let writeString = ""
            do{
                try writeString.write(to:fileURL,atomically: true,encoding: String.Encoding.utf8)
                countLine = 0
            } catch let error as NSError {
                print("fail to write to url")
                print(error)
            }
            
        }
        stopAcc.isEnabled = false
        
    }

    @IBAction func resetLocalfile(_ sender: Any) {
        print("reset local file", "file path : \(fileURL.path)")
//        let fileManager = FileManager.default
        let writeString = ""
        do{
            try writeString.write(to:fileURL,atomically: true,encoding: String.Encoding.utf8)
            countLine = 0
        } catch let error as NSError {
            print("fail to write to url")
            print(error)
        }
        
    }
    @IBAction func sendEmail(_ sender: Any) {
        if(MFMailComposeViewController.canSendMail()){
            print("send mail", "can send")
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            // set subject and message of the email
            mailComposer.setSubject("acce data send at " + DateUtil.stringifyAll(calendar: Date()))
            mailComposer.setMessageBody("acc data is at attachment", isHTML: false)
            
            if let fileData = NSData(contentsOf:self.fileURL) {
                print("send mail","file loaded")
                mailComposer.addAttachmentData(fileData as Data, mimeType: "text/plain", fileName: "Acce_data.txt")
            }
            
            self.present(mailComposer, animated: true, completion: nil)
            
        } else {
            print("send mail", "cannot send")
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startAcc(_ sender: Any) {
//        setAcce()
        if (sampleRate.text != nil) {
            input = sampleRate.text!
            if(input != ""){
                 Hz = Double(input)!
            }
           
        }
        
        setRate.text = "Sample rate : \(Hz)Hz"
        setMotion()
        setupCoreLocation()
        stopAcc.isEnabled = true
        startAcc.isEnabled = false
        emailData.isEnabled = false
        resetfile.isEnabled = false
        self.view.endEditing(true)
    }
    @IBAction func Stopacc(_ sender: Any) {
        
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
        startAcc.isEnabled = true
        emailData.isEnabled = true
        resetfile.isEnabled = true
        stopAcc.isEnabled = false
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
    func appendfile(svm : Double, time : String){
        let dataString = time + "  \(svm)\n"
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


    
    func getAuthorizationSuatus(status: CLAuthorizationStatus)-> String{
        switch status {
            case .authorizedAlways:
                return "Always"
            case .authorizedWhenInUse :
                return "When in use"
            case .denied :
                return "Denied"
            case .notDetermined :
                return "Not determined"
            case .restricted :
                return "Restriceted"
        
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
                    print("acc", " appended \(svm) at " + DateUtil.stringifyAllAlt(calendar: Date()))
                    self.count = 0;
                    self.countLine += 1
                    self.label2.text = DateUtil.stringifyAllAlt(calendar: Date()) + "\n \(svm) \n \(self.countLine)"
                    self.appendfile(dataString: DateUtil.stringifyAllAlt(calendar: Date()) + " \(svm)" + "\n")
                    svm = 0.0;
                    
                }
            }
        }
        
    }
    
    func setMotion(){
        print("setMotion", Hz)
        if motionManager.isDeviceMotionAvailable{
            print("setMotion start")
            motionManager.deviceMotionUpdateInterval = 1.0 / Hz
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!){
                (data, error) in
                if let myData = data {
                    //                print(myData)
                    var svm = myData.userAcceleration.x * myData.userAcceleration.x +
                        myData.userAcceleration.y * myData.userAcceleration.y +
                        myData.userAcceleration.z * myData.userAcceleration.z
                    
                    
                    
                    
                    svm = sqrt(svm) 
                    self.tempSum = self.tempSum + svm
                    self.count = self.count + 1.0
                    if(self.count > self.Hz){
                        print("acc", " appended \(svm) at " + DateUtil.stringifyAllAlt(calendar: Date()))
                        self.count = 0;
                        self.countLine += 1
                        self.label2.text = DateUtil.stringifyAllAlt(calendar: Date()) + "\n \(svm) \n \(self.countLine)"
                        self.appendfile(dataString: DateUtil.stringifyAllAlt(calendar: Date()) + " \(svm)" + "\n")
                        svm = 0.0;
                        
                    }
                }
            }
            
        }
    }
    
    func appendfile(dataString : String){
        
        do{
            let fileHandle = try FileHandle(forWritingTo: self.fileURL)
            fileHandle.seekToEndOfFile()
            fileHandle.write(dataString.data(using: .utf8)!)
            fileHandle.closeFile()
            
        } catch {
            print("Error writing to file \(error)")
        }
    }
    func setFile(){
        fileURL = DocumentDirUrl.appendingPathComponent(fileName).appendingPathExtension("txt")
        print("file path : \(fileURL.path)")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path){
            print("File exist")
        } else {
            print("File not exist")
            let writeString = ""
            do{
                try writeString.write(to:fileURL,atomically: true,encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("fail to write to url")
                print(error)
            }
            
        }
    }
    
    //location service
    var locationFileURL : URL!
    let locationFileName = "locationFileName"
    var locationUploadFlag = false;
    func setupCoreLocation()  {
        print("setupCoreLocation")
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("in setup ","not determined")
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedAlways:
            print("in setup ","authorized")
            enableLocationServices()
        default:
            break
        }
    }
    func enableLocationServices()  {
        if CLLocationManager.locationServicesEnabled(){
            
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            //            locationManager.requestWhenInUseAuthorization()
            
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.distanceFilter = 2
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
            locationFileURL = DocumentDirUrl.appendingPathComponent(locationFileName).appendingPathExtension("txt")
            LocalFileManager.setFile(fileURL: locationFileURL, writeString: "location Service test\n")
        }
    }
    func disableLocationServices(){
        locationManager.stopUpdatingLocation()
    }
    //location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            print("location authorized")
            enableLocationServices()
        case .denied, .restricted:
            print("not authorized")
        default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        print("Date: ",DateUtil.stringifyAll(calendar: Date())," Coord: \(location.coordinate)")
        LocalFileManager.appendfile(fileURL: locationFileURL, dataString: "Date: " + DateUtil.stringifyAll(calendar: Date()) + " Coord: \(location.coordinate)\n")
        let threshold = self.calendar.component(.second, from: Date())
        if(threshold > 30 && !locationUploadFlag){
            locationUploadFlag = true

            print("LocationManager ","location is uploaded")
            
        } else if(threshold != 0) {
            locationUploadFlag = false
        }
    }

}



