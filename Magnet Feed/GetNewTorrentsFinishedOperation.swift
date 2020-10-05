//
//  GetNewTorrentsFinishedOperation.swift
//  Magnet Feed
//
//  Created by Justin Oakes on 6/15/20.
//  Copyright © 2020 Oklasoft. All rights reserved.
//

import Foundation

class GetNewTorrentsFinishedOperation: Operation {
    
    override init() {
        super.init()
        queuePriority = .high
        qualityOfService = .userInitiated
    }
    
    override func main() {
        let predicate = NSPredicate(format: "%K = %@", "reported", NSNumber(booleanLiteral: false))
        let newTorrents = TorrentService.shared.fetchTorrents(predicate: predicate)
        if newTorrents.count > 0 {
            newTorrents.forEach { (torrent) in
                torrent.reported = true
                if let torrentURL = URL(string: torrent.link),
                    let autoDownload = UserDefaultService.getValue(for: .autoDownload) as? Bool,
                   autoDownload {
                    NSWorkspace.shared.open(torrentURL)
                }
            }
            do {
                try CoreDataService.sharedInstance().managedObjectContext.save()
            } catch {
                let alert = NSAlert(error: error)
                alert.runModal()
            }
            let userNotification = NSUserNotification()
            userNotification.title = "New Downloads Available"
            userNotification.informativeText = "New files are ready to be downloaded now"
            userNotification.soundName = NSUserNotificationDefaultSoundName
            NSUserNotificationCenter.default.deliver(userNotification)
        }
        NotificationCenter.default.post(name: .torrentUpdateComplete, object: nil)
    }
}
