//
//  Document.swift
//  Boxy
//
//  Created by Alexandru Rosianu on 13/05/15.
//  Copyright (c) 2015 Aluxian. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    
    

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)!
        let windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
    }
    
    

    override func readFromData(data: NSData, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
        
        /*let oldArchive = ZZArchive(URL: NSURL(fileURLWithPath: filename), error: outError)
            error:nil];
        ZZArchiveEntry* firstArchiveEntry = oldArchive.entries[0];
        NSLog(@"The first entry's uncompressed size is %lu bytes.", (unsigned long)firstArchiveEntry.uncompressedSize);
        NSLog(@"The first entry's data is: %@.", [firstArchiveEntry newDataWithError:nil]);*/
        
        println(typeName)
        println(data)
        
        outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        return false
    }

}
