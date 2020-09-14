//
//  AddSourceView.swift
//  Magnet Feed
//
//  Created by Justin Oakes on 4/10/20.
//  Copyright © 2020 Oklasoft. All rights reserved.
//

import Cocoa

@objc class AddSourceViewController: NSViewController {

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var okButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Add Feed", comment: "Add feed view title")
        view.window?.styleMask.remove(.resizable)
    }

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
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(self)
        guard let url = URL(string: textField.stringValue) else {
            progressIndicator.stopAnimation(self)
            progressIndicator.isHidden = true
            let alert = AlertProvider.alert(for: .invalidURL)
            alert.runModal()
            return
        }
        TorrentService.shared.addSource(url: url) { [weak self] (error, success) in
            DispatchQueue.main.async {
                self?.progressIndicator.stopAnimation(self)
                self?.progressIndicator.isHidden = true
                if success {
                    self?.view.window?.close()
                    return
                } else {
                    if let error = error {
                        let alert = AlertProvider.errorAlert(error: error)
                        alert.runModal()
                        return
                    }
                }
                AlertProvider.alert(for: .cannotAddSource).runModal()
            }
        }
    }

    @IBAction func cancelClicked(_ sender: Any) {
        view.window?.close()
    }
}

extension AddSourceViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else {
            okButton.isEnabled = false
            return
        }
        okButton.isEnabled = textField.stringValue.isValidURL
    }
}
