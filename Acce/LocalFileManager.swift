//
//  LocalFileManager.swift
//  Survey
//
//  Created by Qinjia Huang on 1/8/18.
//  Copyright © 2018 Qinjia Huang. All rights reserved.
//

import UIKit

class LocalFileManager: NSObject {
    static func setFile(fileURL: URL, writeString: String){
        
        print("file path : \(fileURL.path)")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path){
            print("File exist")
        } else {
            print("File not exist")
            
            do{
                try writeString.write(to:fileURL,atomically: true,encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("fail to write to url")
                print(error)
            }
            
        }
    }
    static func appendfile(fileURL:URL, dataString : String){
        
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
    
}
