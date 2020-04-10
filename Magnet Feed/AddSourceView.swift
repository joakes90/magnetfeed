//
//  AddSourceView.swift
//  Magnet Feed
//
//  Created by Justin Oakes on 4/10/20.
//  Copyright © 2020 Oklasoft. All rights reserved.
//

import Cocoa

class AddSourceView: NSViewController {

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var okButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    
    override func viewWillAppear() {
        super.viewWillAppear()
        fixAppearance()
        if let url = pasteboardURL() {
            textField.stringValue = url
        }
    }

    fileprivate func fixAppearance() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Hack around text field vibrancy bug
            let dark = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
            self.textField.becomeFirstResponder()
            self.textField.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
        }
    }
    
    fileprivate func pasteboardURL() -> String? {
        if let string = NSPasteboard.general.string(forType: .string),
            let _ = URL(string: string) {
            return string
        }
        return nil
    }
}
