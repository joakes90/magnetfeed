//
//  SourceService.swift
//  Magnet Feed
//
//  Created by Justin Oakes on 4/15/20.
//  Copyright © 2020 Oklasoft. All rights reserved.
//
 
import Cocoa

class SourceService {

    static let shared = SourceService()

    var sources: [Source] {
        get {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Source.entityName())
            do {
                let sources = try CoreDataService.sharedInstance().managedObjectContext.fetch(fetchRequest) as? [Source]
                return sources?.sorted(by: { $0.dateAdded < $1.dateAdded }) ?? []
                
            } catch {
                // TODO: Handel error
                print(error.localizedDescription)
                return []
            }
        }
    }

    func addSource(url: URL) {
        if JTOXMLParser.validateURLIsFeed(url),
            sources.first(where: { $0.url == url.absoluteString }) == nil {
            let source = NSEntityDescription.insertNewObject(forEntityName: Source.entityName(), into: CoreDataService.sharedInstance().managedObjectContext) as? Source
            source?.url = url.absoluteString
            source?.dateAdded = Date()
            do {
                try CoreDataService.sharedInstance().managedObjectContext.save()
                getNewTorrents()
            } catch {
                _ = AlertProvider.errorAlert(error: error)
            }
        }
        // TODO: tell user unable to add feed
    }
    
    func getNewTorrents(from sources: [Source]? = nil) {
        let sources = sources ?? self.sources
        if sources.isEmpty {
            NotificationCenter.default.post(name: .torrentUpdate, object: nil)
            return
        }
        sources.forEach({ JTOXMLParser.sharedInstance().parse(with: $0) })
    }
}
