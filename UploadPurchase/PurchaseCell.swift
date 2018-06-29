//
//  PurchaseCell.swift
//  UploadPurchase
//
//  Created by Nemo on 2018/6/29.
//  Copyright © 2018年 3K. All rights reserved.
//

import Cocoa

class PurchaseItem {
    var referenceName = ""
    var productID = ""
    var productTitle = ""
    var description = ""
    var screenshortURL = ""
    var productType = "consumable"
    var priceTier = "1"
    var index = 0
}


class PurchaseCell: NSTableCellView {

    
    /// 消费类型
    ///
    /// - consumable: 消耗型项目
    /// - nonConsumable: 非消耗型项目
    /// - autoRenewable: 自动续期订阅
    /// - subscription: 非续期订阅
    enum ProductType: String {
        case consumable = "consumable"
        case nonConsumable = "non-consumable"
        case autoRenewable = "auto-renewable"
        case subscription = "subscription"
    }
    
    @IBOutlet weak var referenceNameField: NSTextField!
    @IBOutlet weak var productIDField: NSTextField!
    @IBOutlet weak var productTitleField: NSTextField!
    @IBOutlet weak var descriptionField: NSTextView!
    @IBOutlet weak var screenshortField: NSTextField!
    
    @IBOutlet weak var priceTierPopBtn: NSPopUpButton! {
        didSet {
            self.settingPriceTiper()
        }
    }
    @IBOutlet weak var productTypePopBtn: NSPopUpButton! {
        didSet {
            self.settingTypePop()
        }
    }

    var index = 0
    private var purshaseItem: PurchaseItem?
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    
    func setPurchaseInfo(_ item: PurchaseItem) {
        
        self.purshaseItem = item
        
        if self.purshaseItem != nil {
            self.referenceNameField.stringValue = (self.purshaseItem?.referenceName)!
            self.productIDField.stringValue = self.purshaseItem!.productID
            self.productTitleField.stringValue = self.purshaseItem!.productTitle
            self.descriptionField.string = self.purshaseItem!.description
            self.screenshortField.stringValue = self.purshaseItem!.screenshortURL
            self.priceTierPopBtn.selectItem(at: Int(self.purshaseItem!.priceTier)! - 1)
            
            var typeNum = 0
            
            switch self.purshaseItem!.productType {
            case ProductType.consumable.rawValue:
                typeNum = 0
            case ProductType.nonConsumable.rawValue:
                typeNum = 1
            case ProductType.autoRenewable.rawValue:
                typeNum = 2
            case ProductType.subscription.rawValue:
                typeNum = 3
            default:
                break
            }
            self.productTypePopBtn.selectItem(at: typeNum)
        }
    }
    
    private func refreshPurchasseItem() {
        purshaseItem!.referenceName = referenceNameField.stringValue
        purshaseItem!.productID = productIDField.stringValue
        purshaseItem!.productTitle = productTitleField.stringValue
        purshaseItem!.description = descriptionField.string
        
        var type:ProductType = .consumable
        switch productTypePopBtn.indexOfSelectedItem {
        case 0:
            type = .consumable
        case 1:
            type = .nonConsumable
        case 2:
            type = .autoRenewable
        case 3:
            type = .subscription
        default:
            break
        }
        
        purshaseItem!.productType = type.rawValue
        
        purshaseItem!.priceTier = "\(priceTierPopBtn.indexOfSelectedItem + 1)"
        
        purshaseItem!.index = index
    }
    
    private func settingPriceTiper() {
        self.priceTierPopBtn.removeAllItems()
        
        var tierList = [String]()
        for i in 1...87 {
            tierList.append("等级\(i)")
        }
        
        self.priceTierPopBtn.addItems(withTitles: tierList)
    }
    
    private func settingTypePop() {
        self.productTypePopBtn.removeAllItems()
        self.productTypePopBtn.addItems(withTitles: ["消耗型", "非消耗型", "自动续期订阅", "非续期订阅"])
    }
    
    @IBAction func didClickProductTypePopBtn(_ sender: NSPopUpButton) {
        self.refreshPurchasseItem()
    }
    
    @IBAction func didClickPriceTierPopBtn(_ sender: NSPopUpButton) {
        self.refreshPurchasseItem()
    }
    
    
    @IBAction func selectPicture(_ sender: NSButton) {
        
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.showsHiddenFiles = false
        openPanel.allowedFileTypes = ["jpg", "png"]
        
        openPanel.beginSheetModal(for:NSApplication.shared.keyWindow!) { (result) in
            // 选择确认按钮
            if result == NSApplication.ModalResponse.OK {
                self.purshaseItem!.screenshortURL = (openPanel.url?.path)!
                self.screenshortField.stringValue = (openPanel.url?.path)!
            }
            // 恢复按钮状态
            sender.state = NSControl.StateValue.off
        }
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return true
    }
}

extension PurchaseCell: NSTextViewDelegate, NSTextFieldDelegate {

    // MARK: - NSControlSubclassNotifications NSTextFieldDelegate
    override func controlTextDidChange(_ obj: Notification) {
        self.refreshPurchasseItem()
    }

    // MARK: - NSTextViewDelegate
    func textDidChange(_ notification: Notification) {
        self.refreshPurchasseItem()
    }
    
}
