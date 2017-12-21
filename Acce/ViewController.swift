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
class ViewController: UIViewController {
    var motionManager = CMMotionManager()
    let Hz = 50.0
    var sum = 0
    var fileName = "rtid_replacement_acce_data"
    let DocumentDirUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    var fileURL : URL! = nil
    var count = 0.0
    var tempSum = 0.0
    var basicUrl = "http://10.120.66.203:8888/TEST.php"
    

    @IBOutlet weak var somex: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        fileURL = DocumentDirUrl.appendingPathComponent(fileName).appendingPathExtension("txt")
        print("file path : \(fileURL.path)")
        let writeString = "ritd replacement\n"
        do{
            try writeString.write(to:fileURL,atomically: true,encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("fail to write to url")
            print(error)
        }
        self.uploadFile(filePath: self.fileURL, uploadURL: self.basicUrl)
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
                    self.appendfile(svm: svm,time: self.stringifyAll(calendar: Date()))
                    svm = 0.0;
                    print(self.readfile())
                    self.uploadFile(filePath: self.fileURL, uploadURL: self.basicUrl)
                    self.somex.text = self.readfile()
//                    print(self.readfile())
                    self.view.reloadInputViews()
                }
                
            }
        }
    }
    func stringifyAll(calendar : Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        return dateFormatter.string(from: calendar)
    }
    
    func uploadFile(filePath : URL, uploadURL: String){
//        print("here to upload")
        Alamofire.upload(
            //同样采用post表单上传
            multipartFormData: { multipartFormData in
                multipartFormData.append(filePath, withName: "uploadedfile", fileName: self.fileName, mimeType: "text/plain")
                //服务器地址
        },to: uploadURL,encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                //json处理
                upload.responseJSON { response in
                    //解包
                    guard let result = response.result.value else { return }
                    print("json:\(result)")
                }
                //上传进度
                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                    print("file upload progress: \(progress.fractionCompleted)")
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
}



