//
//  Document.swift
//  Boxy
//
//  Created by Alexandru Rosianu on 13/05/15.
//  Copyright (c) 2015 Aluxian. All rights reserved.
//

import Cocoa

struct Entry {
    let fileName: String
    let data: NSData
    let size: UInt
    
    init(filename: String, data: NSData, size: UInt) {
        self.fileName = filename
        self.data = data
        self.size = size
    }
    
    init(filename: String, data: NSData) {
        self.fileName = filename
        self.data = data
        self.size = 0
    }
}

class Document: NSDocument, NSTableViewDataSource {
    
    var entries: [Entry] = []
    var saveItem: NSToolbarItem? = nil
    var mountItem: NSToolbarItem? = nil

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }
    
    func extractTo(p: String) {
        let data = dataOfType("Box Image", error: nil)
        let archive = ZZArchive(data: data, error: nil)
        
        let fileManager = NSFileManager()
        let url = NSURL(fileURLWithPath: p, isDirectory: true)!
        fileManager.createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil, error: nil)
        
        for _entry in archive.entries {
            let entry = _entry as! ZZArchiveEntry
            let fn = entry.fileName
            let target = NSURL(fileURLWithPath: url.path! + "/" + fn)
            entry.newDataWithError(nil).writeToURL(target!, atomically: false)
        }
    }

    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)!
        let windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
    }
    
    override func readFromData(data: NSData, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
        let archive = ZZArchive(data: data, error: outError)
        if (outError != nil && outError.memory != nil) {
            println(outError.memory)
        }
        
        if var _entries = archive?.entries {
            var entrs  = _entries as! [ZZArchiveEntry]
            for e in entrs {
                entries.append(Entry(filename: e.fileName, data: e.newDataWithError(outError), size: e.compressedSize))
            }
        } else {
            entries = []
        }
        
        return true
    }
    
    override func dataOfType(typeName: String, error outError: NSErrorPointer) -> NSData? {
        let data = NSMutableData()
        
        let archive = ZZArchive(data: data, options: ["ZZOpenOptionsCreateIfMissingKey": true], error: outError)
        if (outError != nil && outError.memory != nil) {
            println(outError.memory)
        }
        
        archive?.updateEntries(entries.map({ e -> ZZArchiveEntry in
            return ZZArchiveEntry(fileName: e.fileName, compress: true, dataBlock: { (error) -> NSData! in
                return e.data
            })
        }), error: outError)
        if (outError != nil && outError.memory != nil) {
            println(outError.memory)
        }
        
        return data
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return entries.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if "size" == tableColumn?.identifier {
            return entries[row].size
        }
        
        if "name" == tableColumn?.identifier {
            return entries[row].fileName
        }
        
        return nil
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        if "name" == tableColumn?.identifier {
            let o = entries[row]
            entries[row] = Entry(filename: object as! String, data: o.data, size: o.size)
        }
        
        if let item = saveItem {
            item.action = "saveButton:"
            
            if let i2 = mountItem {
                i2.action = nil
            }
        }
    }
    
}
