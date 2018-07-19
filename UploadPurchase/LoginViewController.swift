//
//  LoginViewController.swift
//  UploadPurchase
//
//  Created by Nemo on 2018/7/2.
//  Copyright © 2018年 3K. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {

    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passWordField: NSTextField!
    @IBOutlet weak var appleIDField: NSTextField!
    @IBOutlet weak var tipsField: NSTextField!
    @IBOutlet weak var indicator: NSProgressIndicator!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.indicator.isHidden = true
        let username = UserInfo.fetchUserInfo(UserInfo.usernameKey)
        let password = UserInfo.fetchUserInfo(UserInfo.passwordKey)
        let appleID = UserInfo.fetchUserInfo(UserInfo.appleIDKey)
        if username != nil && password != nil && appleID != nil {
            usernameField.stringValue = username!
            passWordField.stringValue = password!
            appleIDField.stringValue = appleID!
        }
    
    }
    
    @IBAction func didClickLoginBtn(_ sender: NSButton) {
        
        tipsField.stringValue = ""

        if appleIDField.stringValue.count == 0 {
            showWarnning("请输入应用ID")
            return;
        }

        if passWordField.stringValue.count == 0 {
            showWarnning("请输入Apple开发者账号密码")
            return;
        }

        if usernameField.stringValue.count == 0 {
            showWarnning("请输入Apple开发者账号")
            return;
        }
        
        startLogin()
    }
    
    func showWarnning(_ text:String) {
        tipsField.stringValue = "❗️\(text)"
        tipsField.textColor = NSColor.red
    }
    
    func startLogin() {

//        let  xmlProcessor = XMLProcessor()
//
//        xmlProcessor.loadFromFile("\(TaskTool.shared.metadataPath)/\(1039795442).itmsp/metadata.xml")
////        xmlProcessor.loadFromFile("\(TaskTool.shared.metadataPath)/\(appleIDField.stringValue).itmsp/metadata.xml")
//        let item = PurchaseItem()
//        item.priceTier = "商品等级"
//        item.description = "这是商品描述"
//        item.productTitle = "商品标题"
//        item.productID = "商品ID"
//        item.referenceName = "商品应用名"
//        item.productType = "商品类型"
//
//        xmlProcessor.setInAppPurchase(item)
//        return
        
        _ = UserInfo.saveUserInfo(usernameField.stringValue, passWordField.stringValue, appleIDField.stringValue)
        
        indicator.isHidden = false
        indicator.startAnimation(self)
        tipsField.stringValue = "正在登录中..."
        tipsField.textColor = NSColor.black
        TaskTool.shared.executeTransporterInialazation(usernameField.stringValue, password: passWordField.stringValue, appleID: appleIDField.stringValue) {success, errmsg  in
            
            self.indicator.stopAnimation(self)
            
            if success == true {
                self.indicator.isHidden = true
                self.tipsField.stringValue = "✅登录成功"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.presentPurchaseViewController()
                })
            }
            else {
                self.showWarnning(errmsg ?? "登录失败")
            }
        }
    }
    
    func presentPurchaseViewController() {
        
        let nextWindowController = storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("PurchaseWindow")) as! NSWindowController
        nextWindowController.window?.orderFront(nil)
        nextWindowController.window?.center()
        
        self.view.window?.orderOut(nil)
    }
    
}

class ReplacePresentationAnimator: NSObject, NSViewControllerPresentationAnimator {
    func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
        if let window = fromViewController.view.window {
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                fromViewController.view.animator().alphaValue = 0
            }, completionHandler: { () -> Void in
                viewController.view.alphaValue = 0
                window.contentViewController = viewController
                viewController.view.animator().alphaValue = 1.0
            })
        }
    }
    
    func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
        if let window = viewController.view.window {
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                viewController.view.animator().alphaValue = 0
            }, completionHandler: { () -> Void in
                fromViewController.view.alphaValue = 0
                window.contentViewController = fromViewController
                fromViewController.view.animator().alphaValue = 1.0
            })
        }
    }
}
