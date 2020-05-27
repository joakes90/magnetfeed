//
//  NotificationExtensions.swift
//  Magnet Feed
//
//  Created by Justin Oakes on 5/26/20.
//  Copyright © 2020 Oklasoft. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let torrentUpdateStarted = Notification.Name("torrentUpdateStarted")
    static let torrentUpdateComplete = NSNotification.Name("torrentUpdateComplete")
}
