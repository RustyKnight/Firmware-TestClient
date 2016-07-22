//
//  ViewController.swift
//  TestCioffiServer
//
//  Created by Shane Whitehead on 22/07/2016.
//  Copyright © 2016 Beam Communications. All rights reserved.
//

import Cocoa
import CioffiAPI

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try ServerService.default.connect(to: "localhost", port: 51234)
        } catch let error {
            log(error: "\(error)")
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func getVersionAction(_ sender: AnyObject) {
        do {
            try ServerService.default.send(request: .getVersion)
        } catch let error {
            log(error: "\(error)")
        }
    }

}

