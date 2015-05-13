//
//  ViewController.swift
//  Boxy
//
//  Created by Alexandru Rosianu on 13/05/15.
//  Copyright (c) 2015 Aluxian. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var table: NSTableView!
    var doc: Document? = nil
    
    func addButton(sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.beginWithCompletionHandler({ result in
            if (result == NSFileHandlingPanelOKButton) {
                for _url in panel.URLs {
                    let url = _url as! NSURL
                    let m = NSMutableData()
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        m.appendData(NSData(contentsOfURL: url)!)
                    })
                    
                    self.doc!.entries.append(Entry(filename: url.pathComponents!.last as! String, data: m))
                    self.table.reloadData()
                    
                    self.saveItem!.action = "saveButton:"
                    self.mountItem!.action = nil
                }
            }
        })
    }
    
    func removeButton(sender: AnyObject) {
        var i = 0
        while i < self.doc!.entries.count {
            if table.selectedRowIndexes.containsIndex(i) {
                self.doc!.entries.removeAtIndex(i)
            } else {
                i += 1
            }
        }
        
        self.table.reloadData()
        
        saveItem!.action = "saveButton:"
        self.mountItem!.action = nil
    }
    
    func extractButton(sender: AnyObject) {
        var files: [Entry] = []
        
        var i = 0
        while i < self.doc!.entries.count {
            if table.selectedRowIndexes.containsIndex(i) {
                files.append(self.doc!.entries[i])
            }
            i += 1
        }
        
        // Create and configure the panel.
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.beginSheetModalForWindow(self.view.window!, completionHandler: { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                let url = openPanel.URL!
                files.map({ e -> Void in
                    e.data.writeToFile(url.path! + "/" + e.fileName, atomically: false)
                })
            }
        })
    }
    
    func mountButton(sender: AnyObject) {
        self.doc!.extractTo("/Users/aluxian/tmp/" + self.doc!.displayName)
        
        let task1 = NSTask()
        task1.launchPath = "/usr/bin/hdiutil";
        task1.arguments = ["create", "-fs", "HFS+", "-volname", self.doc!.displayName, "-srcfolder", "/Users/aluxian/tmp/" + self.doc!.displayName, "/Users/aluxian/tmp/" + self.doc!.displayName + ".dmg"]
        println(["create", "-fs", "HFS+", "-volname", self.doc!.displayName, "-srcfolder", "/Users/aluxian/tmp/" + self.doc!.displayName, "/Users/aluxian/tmp/" + self.doc!.displayName + ".dmg"])
        task1.launch()
        task1.waitUntilExit()
        
        let task2 = NSTask()
        task2.launchPath = "/usr/bin/open"
        task2.arguments = ["/Users/aluxian/tmp/" + self.doc!.displayName + ".dmg"]
        task2.launch()
        task2.waitUntilExit()
    }
    
    func saveButton(sender: AnyObject) {
        self.doc!.saveDocument(sender)
        self.saveItem!.action = nil
        mountItem!.action = "mountButton:"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var addItem: NSToolbarItem? = nil
    var removeItem: NSToolbarItem? = nil
    var mountItem: NSToolbarItem? = nil
    var saveItem: NSToolbarItem? = nil
    var extractItem: NSToolbarItem? = nil
    
    override func viewDidAppear() {
        let win = self.view.window!
        let ctrl = win.windowController() as! NSWindowController
        doc = ctrl.document! as? Document
        table.setDataSource(doc)
        
        let toolbar = win.toolbar!
        let items = toolbar.items as! [NSToolbarItem]
        
        addItem = items[0]
        removeItem = items[1]
        extractItem = items[2]
        mountItem = items[4]
        saveItem = items[6]
        
        doc?.mountItem = mountItem
        doc?.saveItem = saveItem
        
        addItem!.action = "addButton:"
        removeItem!.action = "removeButton:"
        extractItem!.action = "extractButton:"
        mountItem!.action = "mountButton:"
        //saveItem!.action = "saveButton:"
    }

    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }

}
