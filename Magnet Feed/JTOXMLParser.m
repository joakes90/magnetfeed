//
//  XMLParser.m
//  Magnet Feed
//
//  Created by Justin Oakes on 6/20/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CoreDataService.h"
#import "JTOXMLParser.h"
#import "Magnet_Feed-Swift.h"
#import "Torrent.h"


@interface JTOXMLParser () 

@property (strong, nonatomic) NSMutableDictionary *torrent;

@property (strong, nonatomic) NSMutableArray *arrayOfNewTorrents;

@property (strong, nonatomic) NSString *elementBeingParced;

@property (strong, nonatomic) Source *sourceBeingParced;

@end

@implementation JTOXMLParser

# pragma mark class methods

+ (instancetype) sharedInstance {
    static JTOXMLParser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JTOXMLParser alloc] init];
    });
    return sharedInstance;
}

+ (void) validateURLIsFeed:(NSURL *)url withCompletion: ( void ( ^ ) ( NSError *error, BOOL success) )completion {
    [NetworkService getXMLDataWithSource:url with:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            completion(error, NO);
            return;
        }
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        BOOL success = [parser parse];
        completion(parser.parserError, success);
    }];
}

#pragma mark instance methods

-(void)parseWithSource:(Source *)source {
    self.sourceBeingParced = source;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:source.url]];
    parser.delegate = self;
    
    [parser parse];
}

#pragma mark Torrent collection building methods

-(void) removeDuplicatesFromTorrentsArray {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Torrent"];
    NSArray *existingTorrents = [[CoreDataService sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSMutableArray *torrentsToRemove = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *newTorrent in self.arrayOfNewTorrents) {
        NSString *link = newTorrent[@"link"];
        for (Torrent *oldTorrent in existingTorrents) {
            if ([oldTorrent.link isEqualToString:link]) {
                [torrentsToRemove addObject:newTorrent];
            }
        }
    }
    
    for (Torrent *badTorrent in torrentsToRemove) {
        [self.arrayOfNewTorrents removeObject:badTorrent];
    }
}

-(void)createTorrentManagedObjects {
    NSMutableArray *torrentManagedObjects = [[NSMutableArray alloc] init];
    if (self.arrayOfNewTorrents.count > 0) {
        for (NSMutableDictionary *torrentDictioanry in self.arrayOfNewTorrents) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
            NSDate *date = [dateFormatter dateFromString:torrentDictioanry[@"pubDate"]];
            Torrent *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Torrent" inManagedObjectContext:[CoreDataService sharedInstance].managedObjectContext];
            newManagedObject.name = torrentDictioanry[@"title"];
            newManagedObject.link = torrentDictioanry[@"link"];
            newManagedObject.date = date;
            newManagedObject.source = self.sourceBeingParced;
            [torrentManagedObjects addObject:newManagedObject];
        }
        NSError *error;
        [[CoreDataService sharedInstance].managedObjectContext save:&error];
        NSUserNotification *userNotification = [[NSUserNotification alloc] init];
        userNotification.title = @"New Downloads Available";
        userNotification.informativeText = @"New files are ready to be downloaded now";
        userNotification.soundName = NSUserNotificationDefaultSoundName;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:userNotification];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoDownload"]) {
            for (NSMutableDictionary *torrentDictionary in self.arrayOfNewTorrents) {
                NSURL *downloadURL = [NSURL URLWithString:torrentDictionary[@"link"]];
                [[NSWorkspace sharedWorkspace] openURL:downloadURL];
            }
        }
    }
    NSNotification *notification = [[NSNotification alloc] initWithName:@"torrentUpdateComplete"
                                                                 object:nil
                                                               userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark NSXMLParserDelegate Methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"channel"]) {
        self.arrayOfNewTorrents = [[NSMutableArray alloc] init];
    }
    
    if ([elementName isEqualToString:@"enclosure"]) {
        self.torrent[@"link"] = attributeDict[@"url"];
    }

    if ([elementName isEqualToString:@"item"]) {
        self.torrent = [[NSMutableDictionary alloc] init];
    }
    
    self.elementBeingParced = elementName;
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([self.elementBeingParced isEqualToString:@"title"] && [string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length != 0) {
        self.torrent[@"title"] = string;
    }
    if ([self.elementBeingParced isEqualToString:@"pubDate"]) {
        self.torrent[@"pubDate"] = string;
    }
}


-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"item"]) {
        [self.arrayOfNewTorrents addObject:self.torrent];
    }
    if ([elementName isEqualToString:@"channel"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeDuplicatesFromTorrentsArray];
            [self createTorrentManagedObjects];
        });
        
    }
}

@end
