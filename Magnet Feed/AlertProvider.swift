//
//  AlertProvider.swift
//  Magnet Feed
//
//  Created by Justin Oakes on 5/26/20.
//  Copyright © 2020 Oklasoft. All rights reserved.
//

import Cocoa

class AlertProvider {
    
    enum AlertType {
        case invalidURL
        case cannotAddSource
    }
    
    static func alert(for type: AlertType) -> NSAlert {
        let alert = NSAlert()
        switch type {
        case .invalidURL:
            alert.messageText = NSLocalizedString("Invalid URL", comment: "invalid URL alert title")
            alert.informativeText = NSLocalizedString("This is not a valid URL", comment: "Invalid URL alert infomation text")
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Ok")
        case .cannotAddSource:
            alert.messageText = NSLocalizedString("Could not add source", comment: "failed to add source to core data alert title")
            alert.informativeText = NSLocalizedString("This URL could not be added. Please make sure this is a valid RSS URL and try again later", comment: "failed to add source to core data information text")
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Ok")
        }
        return alert
    }
    
    static func errorAlert(error: Error) -> NSAlert {
        return NSAlert(error: error)
    }
}
