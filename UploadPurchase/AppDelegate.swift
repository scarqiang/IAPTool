//
//  AppDelegate.swift
//  UploadPurchase
//
//  Created by Nemo on 2018/6/28.
//  Copyright © 2018年 3K. All rights reserved.
//

import Cocoa
import CryptoSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag == false {
            
            for window in sender.windows {
                
                if (window.delegate?.isKind(of: NSWindowController.self)) == true {
                    window.makeKeyAndOrderFront(self)
                }
            }
        }
        return true
    }
    
}

