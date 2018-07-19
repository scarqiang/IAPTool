//
//  TaskTool.swift
//  UploadPurchase
//
//  Created by Nemo on 2018/7/2.
//  Copyright © 2018年 3K. All rights reserved.
//

import Cocoa
import CryptoSwift

final class TaskTool {
    
    private init() { }
    static let shared = TaskTool()
    private var transporterPath: String {
        get {
            return "/usr/local/itms/bin/iTMSTransporter"
        }
    }
    
    private var destinationPath: String {
        get {
            let libraryPath = getAppLibraryPath()
            return "\(libraryPath)/Transporter"
        }
    }
    
    private var backupsPath: String {
        get {
            
            let path = "\(self.destinationPath)/backup"
            
            if FileManager.default.fileExists(atPath: path) == false {
                do {
                    try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("ERROR: Replace Tarrget Itmsp error: \(error.localizedDescription)")
                }
            }
            
            let appleID = UserInfo.fetchUserInfo(UserInfo.appleIDKey)!
            return "\(destinationPath)/backup/\(appleID).itmsp"
        }
    }
    
    var metadataPath: String {
        get {
            return "\(self.destinationPath)/metadata"
        }
    }
    
    var taggertAppMetadatPath: String {
        get {
            let appleID = UserInfo.fetchUserInfo(UserInfo.appleIDKey)!
            return "\(metadataPath)/\(appleID).itmsp"
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
                
                do {
                    try FileManager.default.copyItem(atPath: self.taggertAppMetadatPath, toPath: self.backupsPath)
                } catch {
                    print("ERROR: Copy Tarrget Itmsp error: \(error.localizedDescription)")
                }
                
                let success = process.terminationStatus == 0
                let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
                let errStr = String.init(data: errData, encoding: .utf8)
                
                complition(success, errStr)
            }
        }
        task.launch()
        task.waitUntilExit()
    }
    
    func submitPurchase(_ complition: @escaping (_ success: Bool, _ errmsg: String?) -> Void) {
        let task = Process()
        task.launchPath = self.transporterPath
        task.arguments = ["-m", "upload", "-f", self.taggertAppMetadatPath, "-u", UserInfo.fetchUserInfo(UserInfo.usernameKey), "-p", UserInfo.fetchUserInfo(UserInfo.passwordKey), "-v", "eXtreme", "-t", "DAV", "-errorLogs", "\(destinationPath)/errorlog"] as? [String]
        
        
        
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
    
    func deleteTaggertItmsp() {
        do {
            try FileManager.default.removeItem(atPath: self.taggertAppMetadatPath)
            try FileManager.default.removeItem(atPath: self.backupsPath)
        } catch {
            print("ERROR: Remove Tarrget Itmsp error: \(error.localizedDescription)")
        }
    }
    
    func replaceTaggertItmsp() {
        
        let orignXmlPath = "\(self.taggertAppMetadatPath)/metadata.xml"
        let backupsXmlPath = "\(self.backupsPath)/metadata.xml"
        
        do {
            try FileManager.default.removeItem(atPath: orignXmlPath)
            try FileManager.default.copyItem(atPath: backupsXmlPath, toPath: orignXmlPath)
        } catch {
            print("ERROR: Replace Tarrget Itmsp error: \(error.localizedDescription)")
        }
    }
}

class UserInfo {
    static let usernameKey = "apple_dev_username"
    static let passwordKey = "apple_dev_password"
    static let appleIDKey = "apple_dev_appleID"
    private static let aesKey = "ShibaInuShibaInu"
    private static let aesIv = "ShibaInuShibaInu"
    
    class func saveUserInfo(_ userName:String, _ password: String, _ appleID: String) {
        
        let enUsername = Endcode_AES_ECB(strToEncode: userName)
        let enPassword = Endcode_AES_ECB(strToEncode: password)
        let enAppleID = Endcode_AES_ECB(strToEncode: appleID)
        
        UserDefaults.standard.set(enUsername, forKey: usernameKey)
        UserDefaults.standard.set(enPassword, forKey: passwordKey)
        UserDefaults.standard.set(enAppleID, forKey: appleIDKey)
        UserDefaults.standard.synchronize()
    }
    
    class func fetchUserInfo(_ key:String) -> String? {
        
        let encode = UserDefaults.standard.value(forKey: key) as? String
        
        if encode == nil {
            return nil
        }
        
        return Decode_AES_ECB(strToDecode: encode!)
    }
    
    class func clearUserInfo() {
        UserDefaults.standard.removeObject(forKey: usernameKey)
        UserDefaults.standard.removeObject(forKey: passwordKey)
        UserDefaults.standard.removeObject(forKey: appleIDKey)
        UserDefaults.standard.synchronize()
    }
    
    public static func Endcode_AES_ECB(strToEncode:String)->String {
        // 从String 转成data
        let data = strToEncode.data(using: String.Encoding.utf8)
        
        // byte 数组
        var encrypted: [UInt8] = []
        do {
            
            encrypted = try AES(key: aesKey.bytes, blockMode: CBC(iv: aesIv.bytes), padding: .pkcs7).encrypt(data!.bytes)
        } catch {
            
        }
        
        let encoded =  Data(encrypted)
        //加密结果要用Base64转码
        return encoded.base64EncodedString()
    }
    
    //  MARK:  AES-ECB128解密
    public static func Decode_AES_ECB(strToDecode:String)->String {
        //decode base64
        let data = Data(base64Encoded: strToDecode, options: Data.Base64DecodingOptions.init(rawValue: 0))
        // decode AES
        var decrypted: [UInt8] = []
        do {
            
            decrypted = try AES(key: aesKey.bytes, blockMode: CBC(iv: aesIv.bytes), padding: .pkcs7).decrypt(data!.bytes)
        } catch {
        }
        
        // byte 转换成NSData
        let encoded = Data(decrypted)
        var str = ""
        //解密结果从data转成string
        str = String(bytes: encoded.bytes, encoding: .utf8)!
        return str
    }
    
}


