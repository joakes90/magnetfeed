//
//  SourceService.swift
//  Magnet Feed
//
//  Created by Justin Oakes on 4/15/20.
//  Copyright © 2020 Oklasoft. All rights reserved.
//
 
import Cocoa

@objc class SourceService: NSObject {

    @objc static let shared = SourceService()

    private override init() {}
    
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

    @objc func addSource(url: URL, completion: @escaping (Error?, Bool) -> Void) {
        JTOXMLParser.validateURLIsFeed(url) { [weak self] (error, success) in
            if error != nil || (self?.sources.first(where:  { $0.url == url.absoluteString })) != nil {
                completion(error, false)
                return
            }
            let source = NSEntityDescription.insertNewObject(forEntityName: Source.entityName(), into: CoreDataService.sharedInstance().managedObjectContext) as? Source
            source?.url = url.absoluteString
            source?.dateAdded = Date()
            do {
                try CoreDataService.sharedInstance().managedObjectContext.save()
                self?.getNewTorrents()
                completion(nil, true)
            } catch {
                completion(error, false)
            }
        }
    }
    
    @objc func getNewTorrents(from sources: [Source]? = nil) {
        let sources = sources ?? self.sources
        if sources.isEmpty {
            NotificationCenter.default.post(name: .torrentUpdate, object: nil)
            return
        }
        sources.forEach({ JTOXMLParser.sharedInstance().parse(with: $0) })
    }
}
