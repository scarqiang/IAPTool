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

    let languageXPath = ".//package/software/software_metadata/versions/version/locales/locale"
    
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
        node.detach()
    
        
        
        let xmlData = xmlDoc?.xmlData(options: .nodePrettyPrint)
        do {
            let newURL = URL(fileURLWithPath: "/Users/mohansihai/Desktop/FileViewer_final/xxx.xml")
            try xmlData?.write(to: newURL)
        } catch  {
            
        }
        
        return true
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
    
    
    
}
