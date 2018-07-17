//
//  SubmitViewController.swift
//  UploadPurchase
//
//  Created by Nemo on 2018/7/17.
//  Copyright © 2018年 3K. All rights reserved.
//

import Cocoa

class SubmitViewController: NSViewController {

    @IBOutlet weak var loadingView: NSProgressIndicator!
    @IBOutlet weak var tipsLabel: NSTextField!
    @IBOutlet var showInfoTextView: NSTextView!
    @IBOutlet weak var exitBtn: NSButton!
    
    var result = false
    
    var outputPipe = Pipe()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        loadingView.startAnimation(self);
        TaskTool.shared.submitPurchase { (success, errorMsg) in
            self.loadingView.stopAnimation(self)
            self.loadingView.isHidden = true
            self.result = success
            if (success) {
                self.tipsLabel.stringValue = "✅上传成功"
                self.exitBtn.title = "退出"
            }
            else {
                self.tipsLabel.stringValue = "❌上传成功失败"
            }
            
            self.showInfoTextView.string = errorMsg ?? ""
        };
    }
    
    
    @IBAction func exit(_ sender: Any) {
        if self.result {
            TaskTool.shared.deleteTaggertItmsp()
            NSApp.terminate(nil)
        }
        else {
            TaskTool.shared.replaceTaggertItmsp()
            dismissViewController(self)
        }
    }
    
}
