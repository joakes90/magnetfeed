//
//  SourceService.swift
//  Magnet Feed
//
//  Created by Justin Oakes on 4/15/20.
//  Copyright © 2020 Oklasoft. All rights reserved.
//
 
import Foundation

class SourceService {

    class func addSource(url: URL) {
        if JTOXMLParser.validateURLIsFeed(url) {
            
        }
    }
    
    var sources: [Source] {
        get {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Source")
            do {
                let sources = try Stack.sharedInstance()?.managedObjectContext.fetch(fetchRequest) as? [Source]
                return sources?.sorted(by: { $0.dateAdded < $1.dateAdded }) ?? []
                
            } catch {
                // TODO: Handel erro
                print(error.localizedDescription)
                return []
            }
        }
    }
}

//- (IBAction)addSource:(id)sender {
//    NSString *urlString = self.urlTextField.stringValue;
//    if ([XMLParser validateURLIsFeed:urlString]) {
//        BOOL duplicate = NO;
//        for (Source *source in self.sources) {
//            if ([source.url isEqualToString:urlString]) {
//                duplicate = YES;
//            }
//        }
//
//        if (!duplicate) {
//            Source *newSource = [NSEntityDescription insertNewObjectForEntityForName:@"Source" inManagedObjectContext:[Stack sharedInstance].managedObjectContext];
//            newSource.url = urlString;
//            [[Stack sharedInstance].managedObjectContext save:nil];
//            self.sources = [[Stack sharedInstance].managedObjectContext executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Source"] error:nil];
//            AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
//            [appDelegate getNewTorrents];
//        } else {
//            // TODO: Tell the user that feed already exists
//        }
//        [self.tableView reloadData];
//        [self.addFeedWindow close];
//    }
//}
