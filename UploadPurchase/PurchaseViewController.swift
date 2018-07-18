//
//  ViewController.swift
//  UploadPurchase
//
//  Created by Nemo on 2018/6/28.
//  Copyright © 2018年 3K. All rights reserved.
//

import Cocoa

class PurchaseViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var purchaseNumber: NSTextField!
    @IBOutlet weak var tipsTextField: NSTextField!
    @IBOutlet weak var indicator: NSProgressIndicator!
    @IBOutlet weak var submitBtn: NSButton!
    
    var purchaseItems:[PurchaseItem] = [PurchaseItem()] {
        didSet {
            self.purchaseNumber.stringValue = "商品总数：\(self.purchaseItems.count)"
        }
    }
    let cellIndentifier = "PurchaseCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tipsTextField.isHidden = true
        indicator.isHidden = true
    
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func didClickAddItemBtn(_ sender: NSButton) {
        let item = PurchaseItem()
        item.index = purchaseItems.count
        purchaseItems.append(item)
        tableView.reloadData()
        tableView.scrollRowToVisible(purchaseItems.count - 1)
    }
    
    
    @IBAction func didClickRemoveItemBtn(_ sender: NSButton) {
        
        if tableView.selectedRow == -1 {
            return
        }
        
        purchaseItems.remove(at: tableView.selectedRow)
        tableView.reloadData()
    }
    
    @IBAction func didClickSubmit(_ sender: NSButton) {
//        let nextViewController = storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("submitViewController")) as! NSViewController
//        self.presentViewController(nextViewController, animator: ReplacePresentationAnimator())
        
        indicator.isHidden = false
        tipsTextField.isHidden = false
        submitBtn.isEnabled = false
        
        indicator.startAnimation(self)
        tipsTextField.stringValue = "正在检查商品信息..."
        
        
        let result = checkPurchaseItems()
        if result == false {
            indicator.stopAnimation(self)
            indicator.isHidden = true
            submitBtn.isEnabled = true
            return
        }
        else {
            tipsTextField.stringValue = "正在保存商品信息..."
            let  xmlProcessor = XMLProcessor()
            _ = xmlProcessor.loadFromFile("\(TaskTool.shared.taggertAppMetadatPath)/metadata.xml")
            for item in purchaseItems {
                xmlProcessor.setInAppPurchase(item)
            }
            tipsTextField.stringValue = ""
            //submit...
            showSumbitViewController()
        }
        
        
        
        indicator.stopAnimation(self)
        indicator.isHidden = true
        submitBtn.isEnabled = true
        
    }
    
    func checkPurchaseItems() -> Bool {
        
        if purchaseItems.count == 0 {
            tipsTextField.stringValue = "❗️商品信息缺失"
            return false
        }
        
        for item in purchaseItems {
            if item.description.isEmpty || item.priceTier.isEmpty || item.productID.isEmpty || item.productType.isEmpty || item.productTitle.isEmpty || item.screenshortURL.isEmpty || item.referenceName.isEmpty {
                tipsTextField.stringValue = "❗️商品信息缺失，请检查第\(item.index + 1)个商品\"\(item.productTitle)\"的配置信息"
                tableView.scrollRowToVisible(item.index)
                return false
            }
            
            if item.description.count < 10 {
                tipsTextField.stringValue = "❗️商品描述不能少于10个字，请检查第\(item.index + 1)个商品\"\(item.productTitle)\"的配置信息"
                tableView.scrollRowToVisible(item.index);
                return false;
            }
        }
        return true
    }
    
    
    func showSumbitViewController() {
        
        let nextViewController = storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SubmitViewController")) as! SubmitViewController
        self.presentViewControllerAsSheet(nextViewController)
    
    }
}

extension PurchaseViewController:  NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return purchaseItems.count;
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIndentifier), owner: self) as? PurchaseCell {
            cell.index = row
            cell.setPurchaseInfo(purchaseItems[row])
            return cell
        }
        
        return nil
    }
}


