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

    override func viewWillAppear() {
        super.viewWillAppear()
        fixAppearance()
        if let url = pasteboardURL(),
        url.isValidURL {
            textField.stringValue = url
            okButton.isEnabled = true
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
        if let string = NSPasteboard.general.string(forType: .string) {
            return string
        }
        return nil
    }

    @IBAction func okClicked(_ sender: Any) {
        guard let url = URL(string: textField.stringValue) else {
            // TODO: Create alert saying this is not a valid url
            return
        }
        SourceService.shared.addSource(url: url)
    }
}

extension AddSourceView: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else {
            okButton.isEnabled = false
            return
        }
        okButton.isEnabled = textField.stringValue.isValidURL
    }
}
