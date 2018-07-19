//
//  XMLProcessor.swift
//  UploadPurchase
//
//  Created by Nemo on 2018/7/3.
//  Copyright © 2018年 3K. All rights reserved.
//

import Cocoa

class XMLProcessor {
    
    var xmlDoc: XMLDocument?
    var pathToXml: String?
    var language: String?

    let languageXPath = "/package/software/software_metadata/versions/version/locales/locale"
    
    func loadFromFile(_ path:String) -> Bool {
        
        xmlDoc = nil
        pathToXml = nil
        language = nil
        
        let fUrl: URL? = URL(fileURLWithPath: path)
        if fUrl == nil {
            print("Can't create an URL from file \(path)")
            return false
        }
        
        var xml: XMLDocument?
        
        do {
             xml = try XMLDocument.init(contentsOf: fUrl!, options: [.nodePreserveWhitespace, .nodePreserveCDATA])
        } catch {
            print("Can't load XML file, reason: \(error.localizedDescription)")
            return false
        }
        
        if xml == nil {
            do {
                xml = try XMLDocument.init(contentsOf: fUrl!, options: .documentTidyXML)
            } catch {
                print("Can't load XML file, reason: \(error.localizedDescription)")
                return false
            }
        }
        
        xmlDoc = xml
        pathToXml = path
        
        let locales = execXPath(languageXPath)
        let node = locales?.first as! XMLElement
        let nodeAttr = node.attributes?.first
        language = nodeAttr?.stringValue
        
        detachPreviousPurchase()
        
        return true
    }
    
    func saveToFile(_ filePath:String) -> Bool {
        if xmlDoc == nil {
            print("ERROR: XML not loaded to save it in file \(filePath)")
            return false
        }
        
        let xmlData = xmlDoc?.xmlData(options: .nodePrettyPrint)
        do {
            
            let newURL = URL(fileURLWithPath: filePath)
            try xmlData?.write(to: newURL)
            
        } catch  {
            print("ERROR while saving XML to file \(filePath)")
            return false
        }
        
        return true
    }
    
    func overwrite() {
        _ = saveToFile(pathToXml!)
    }
    
    func execXPath(_ xPath:String) -> [XMLNode]? {
        if xmlDoc == nil {
            print("ERROR: XML wasn't loaded before query \(xPath)")
            return nil;
        }
        
        do {
           let nodes = try xmlDoc?.nodes(forXPath: xPath)
            return nodes
        } catch {
            print("ERROR \(error.localizedDescription) while executing xPath \(xPath)")
            return nil
        }
    }
    
    // MARK: XML Info
    func getInAppPurchase(_ index:Int) -> PurchaseItem {
        let item = PurchaseItem()
        let xmlIndex = index + 1
        item.productID = getInAppPurchaseProductID(xmlIndex)
        item.referenceName = getInAppPurchaseReferenceName(xmlIndex)
        item.productType = getInAppPurchaseType(xmlIndex)
        item.productTitle = getInAppPurchaseTitle(xmlIndex)
        item.description = getInAppPurchaseDescription(xmlIndex)
        item.priceTier = getInAppPurchasePriceTier(xmlIndex)
        item.screenshortURL = getInAppPurchaseScreenshort(xmlIndex)
        item.index = index
        return item
    }
    
    func getInAppPurchaseProductID(_ index:Int) -> String {
        let xpath = "/package/software/software_metadata/in_app_purchases/in_app_purchase[\(index)]/product_id"
        let productIDs = execXPath(xpath)
        let node = productIDs?.first
        let productID = node?.stringValue
        return productID ?? ""
    }
    
    
    func getInAppPurchaseReferenceName(_ index:Int) -> String {
        let xpath = "/package/software/software_metadata/in_app_purchases/in_app_purchase[\(index)]/reference_name"
        let referenceNames = execXPath(xpath)
        let node = referenceNames?.first
        let referenceName = node?.stringValue
        return referenceName ?? ""
    }
    
    func getInAppPurchaseType(_ index:Int) -> String {
        let xpath = "/package/software/software_metadata/in_app_purchases/in_app_purchase[\(index)]/type"
        let referenceNames = execXPath(xpath)
        let node = referenceNames?.first
        let referenceName = node?.stringValue
        return referenceName ?? ""
    }
    
    func getInAppPurchaseTitle(_ index:Int) -> String {
        let xpath = "/package/software/software_metadata/in_app_purchases/in_app_purchase[\(index)]/locales/locale[1]/title"
        let titles = execXPath(xpath)
        let node = titles?.first
        let title = node?.stringValue
        return title ?? ""
    }
    
    func getInAppPurchaseDescription(_ index:Int) -> String {
        let xpath = "/package/software/software_metadata/in_app_purchases/in_app_purchase[\(index)]/locales/locale[1]/description"
        let descriptions = execXPath(xpath)
        let node = descriptions?.first
        let description = node?.stringValue
        return description ?? ""
    }
    
    func getInAppPurchasePriceTier(_ index:Int) -> String {
        let xpath = "/package/software/software_metadata/in_app_purchases/in_app_purchase[\(index)]/products/product[1]/intervals/interval[1]/wholesale_price_tier"
        let priceTiers = execXPath(xpath)
        let node = priceTiers?.first
        let priceTier = node?.stringValue
        return priceTier ?? ""
    }
    
    func getInAppPurchaseScreenshort(_ index:Int) -> String {
        let xpath = "/package/software/software_metadata/in_app_purchases/in_app_purchase[\(index)]/review_screenshot/file_name"
        let file_names = execXPath(xpath)
        let node = file_names?.first
        let file_name = node?.stringValue
        return file_name ?? ""
    }
    
    // MARK: Modifying XML
    func detachPreviousPurchase() {
        let purchaseElementPath = "/package/software/software_metadata/in_app_purchases/in_app_purchase"
        let purchaseArr = execXPath(purchaseElementPath)
        
        if purchaseArr?.count == 0 {
            return
        }
        
        for purchase in purchaseArr! {
            purchase.detach()
        }
        
        overwrite()
    }
    
    
    func setInAppPurchase(_ item: PurchaseItem) {
        let purchasesXPath = "/package/software/software_metadata/in_app_purchases"
        let purchases = execXPath(purchasesXPath)
        let purchaseElement = XMLElement.init(name: "in_app_purchase")
        var purchasesElement :XMLElement?
        
        if purchases?.count == 0 {
            let metadatasXPath = "/package/software/software_metadata"
            let metadatas = execXPath(metadatasXPath)
            let metadata = metadatas?.first as! XMLElement
            purchasesElement = XMLElement.init(name: "in_app_purchases")

            metadata.addChild(purchasesElement!)
        }
        else {
            purchasesElement = purchases?.first as? XMLElement
        }
        
        purchasesElement?.addChild(purchaseElement)
        
        let localesElement = setPurchase(title: item.productTitle, description: item.description)
        purchaseElement.addChild(localesElement)
        
        let productIDElement = setPurchase(productID: item.productID)
        purchaseElement.addChild(productIDElement)
        
        let referenceNameElement = setPurchasee(referenceName: item.referenceName)
        purchaseElement.addChild(referenceNameElement)
        
        let typeElement = setPurchasee(type: item.productType)
        purchaseElement.addChild(typeElement)
        
        let tierElement = setPurchase(priceTier: item.priceTier)
        purchaseElement.addChild(tierElement)
        
        let screenshotElement = setPurchase(screenshotURL: item.screenshortURL)
        purchaseElement.addChild(screenshotElement)
        
        overwrite()
    }
    
    func setPurchase(title:String, description:String) -> XMLElement {
        let localesElement = XMLElement(name: "locales")
        let localeElement = XMLElement(name: "locale")
        localeElement.addAttribute(XMLNode.attribute(withName: "name", stringValue: language!) as! XMLNode)
        let titleElement = XMLElement(name: "title")
        titleElement.stringValue = title
        
        let descriptionElement = XMLElement(name: "description")
        descriptionElement.stringValue = description.replacingOccurrences(of: "\n", with: "\r")
        
        localeElement.addChild(titleElement)
        localeElement.addChild(descriptionElement)
        localesElement.addChild(localeElement)
        return localesElement
    }
    
    func setPurchase(productID:String) -> XMLElement {
        let productIDElement = XMLElement(name: "product_id")
        productIDElement.stringValue = productID
        return productIDElement
    }
    
    func setPurchasee(referenceName:String) -> XMLElement {
        let referenceNameElement = XMLElement(name: "reference_name")
        referenceNameElement.stringValue = referenceName
        return referenceNameElement
    }
    
    func setPurchasee(type: String) -> XMLElement {
        let typeElement = XMLElement(name: "type")
        typeElement.stringValue = type
        return typeElement
    }
    
    func setPurchase(priceTier: String) -> XMLElement {
        let productsElement = XMLElement(name: "products")
        let productElement = XMLElement(name: "product")
        
        let cleared_for_saleElement = XMLElement(name: "cleared_for_sale")
        cleared_for_saleElement.stringValue = "true"
        productElement.addChild(cleared_for_saleElement)
        
        let intervalsElement = XMLElement(name: "intervals")
        
        let intervalElement = XMLElement(name: "interval")
        
        let wholesale_price_tierElement = XMLElement(name: "wholesale_price_tier")
        wholesale_price_tierElement.stringValue = priceTier
        
        intervalElement.addChild(wholesale_price_tierElement)
        intervalsElement.addChild(intervalElement)
        
        productElement.addChild(intervalsElement)
        
        productsElement.addChild(productElement)
        
        return productsElement
    }
    
    func setPurchase(screenshotURL: String) -> XMLElement {
        let fileName = (screenshotURL as NSString).lastPathComponent
        
        let review_screenshot = XMLElement(name: "review_screenshot")
        let file_name = XMLElement(name: "file_name");
        file_name.stringValue = fileName;
        
        let size = XMLElement(name: "size")
        size.stringValue = fileSize(path: screenshotURL)
        
        let checksum = XMLElement(name: "checksum")
        checksum.addAttribute(XMLNode.attribute(withName: "type", stringValue: "md5") as! XMLNode)
        checksum.stringValue = fileMD5(screenshotURL)
        
        review_screenshot.addChild(file_name)
        review_screenshot.addChild(size)
        review_screenshot.addChild(checksum)
        
        return review_screenshot
    }
    
    
    // MARK: Help Method
    func fileMD5(_ path: String) -> String? {
        
        let handle = FileHandle(forReadingAtPath: path)
        
        if handle == nil {
            return nil
        }
        
        let ctx = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: MemoryLayout<CC_MD5_CTX>.size)
        
        CC_MD5_Init(ctx)
        
        var done = false
        
        while !done {
            let fileData = handle?.readData(ofLength: 256)
            
            fileData?.withUnsafeBytes {(bytes: UnsafePointer<CChar>)->Void in
                //Use `bytes` inside this closure
                //...
                CC_MD5_Update(ctx, bytes, CC_LONG(fileData!.count))
            }
            
            if fileData?.count == 0 {
                done = true
            }
        }
        
        //unsigned char digest[CC_MD5_DIGEST_LENGTH];
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let digest = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5_Final(digest, ctx);
        
        var hash = ""
        for i in 0..<digestLen {
            hash +=  String(format: "%02x", (digest[i]))
        }
        
        digest.deinitialize(count: 1)
        ctx.deinitialize(count: 1)
        
        return hash;
    }
    
    func fileSize(path: String) -> String {
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            let fileSize = attr[FileAttributeKey.size] as! UInt64
            return "\(fileSize)"
        } catch  {
            return ""
        }
    }
    
}



