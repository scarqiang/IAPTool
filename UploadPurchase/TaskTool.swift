//
//  TaskTool.swift
//  UploadPurchase
//
//  Created by Nemo on 2018/7/2.
//  Copyright © 2018年 3K. All rights reserved.
//

import Cocoa

final class TaskTool {
    
    private init() { }
    static let shared = TaskTool()
    private var transporterPath: String {
        get {
            return "\(self.destinationPath)/itms/bin/iTMSTransporter"
        }
    }
    
    private var destinationPath: String {
        get {
            let libraryPath = getAppLibraryPath()
            return "\(libraryPath)/Transporter"
        }
    }
    
    
    var metadataPath: String {
        get {
            return "\(self.destinationPath)/metadata"
        }
    }
    
    // MARK: File Path
    func getAppLibraryPath() -> String {
        //非沙盒Documents路径：/Users/username/Library/Transporter
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return documentPaths.first!
    }
    
    // MARK: Task
    func executeTransporterInialazation(_ username:String, password:String, appleID:String, complition: @escaping (_ success: Bool, _ errmsg: String?)->Void) {
        
        let mgr = FileManager.default
        if mgr.fileExists(atPath: transporterPath) == false {
            complition(false, "请配置运行环境")
            return
        }
        
        let task = Process()
        task.launchPath = self.transporterPath
        task.arguments = ["-m", "lookupMetadata", "-u", username, "-p", password, "-apple_id", appleID, "-destination", metadataPath]
        
        let errPipe = Pipe()
        task.standardError = errPipe;
        
        task.terminationHandler = { process in              // 执行结束的闭包(回调)
            DispatchQueue.main.async {
                
                let success = process.terminationStatus == 0
                let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
                let errStr = String.init(data: errData, encoding: .utf8)
                
                complition(success, errStr)
            }
        }
        task.launch()
        task.waitUntilExit()
    }
}

class UserInfo {
    static let usernameKey = "apple_dev_username"
    static let passwordKey = "apple_dev_password"
    static let appleIDKey = "apple_dev_appleID"
    
    class func saveUserInfo(_ userName:String, _ password: String, _ appleID: String) {
        UserDefaults.standard.set(userName, forKey: usernameKey)
        UserDefaults.standard.set(password, forKey: passwordKey)
        UserDefaults.standard.set(appleID, forKey: appleIDKey)
        UserDefaults.standard.synchronize()
    }
    
    class func fetchUserInfo(_ key:String) -> String? {
        
        return UserDefaults.standard.value(forKey: key) as? String
    }
    
}

