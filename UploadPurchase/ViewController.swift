//
//  ViewController.swift
//  UploadPurchase
//
//  Created by Nemo on 2018/6/28.
//  Copyright © 2018年 3K. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var purchaseNumber: NSTextField!
    
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
        
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func didClickAddItemBtn(_ sender: NSButton) {
        purchaseItems.append(PurchaseItem())
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
    
}

extension ViewController:  NSTableViewDataSource, NSTableViewDelegate {
    
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

