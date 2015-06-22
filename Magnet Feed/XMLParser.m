//
//  XMLParser.m
//  Magnet Feed
//
//  Created by Justin Oakes on 6/20/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import "XMLParser.h"
#import "Stack.h"
#import "Torrent.h"


@interface XMLParser () 

@property (strong, nonatomic) NSMutableDictionary *torrent;

@property (strong, nonatomic) NSMutableArray *arrayOfNewTorrents;

@property (strong, nonatomic) NSString *elementBeingParced;

@property (strong, nonatomic) Source *sourceBeingParced;

@end

@implementation XMLParser

+ (instancetype) sharedInstance {
    static XMLParser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[XMLParser alloc] init];
    });
    return sharedInstance;
}

-(void)parseWithSource:(Source *)source {
    self.sourceBeingParced = source;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:source.url]];
    parser.delegate = self;
    
    [parser parse];
}

#pragma mark Torrent collection building methods

-(void) removeDuplicatesFromTorrentsArray {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Torrent"];
    NSArray *existingTorrents = [[Stack sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
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
    NSLog(@"%@", self.arrayOfNewTorrents);
    [self createTorrentManagedObjects];
}

-(void)createTorrentManagedObjects {
    for (NSMutableDictionary *torrentDictioanry in self.arrayOfNewTorrents) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
        NSDate *date = [dateFormatter dateFromString:torrentDictioanry[@"pubDate"]];
        Torrent *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Torrent" inManagedObjectContext:[Stack sharedInstance].managedObjectContext];
        newManagedObject.name = torrentDictioanry[@"title"];
        newManagedObject.link = torrentDictioanry[@"link"];
        newManagedObject.date = date;
        newManagedObject.source = self.sourceBeingParced;
    }
    [[Stack sharedInstance].managedObjectContext save:nil];
}

#pragma mark NSXMLParserDelegate Methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"channel"]) {
        self.arrayOfNewTorrents = [[NSMutableArray alloc] init];
    }
    if ([elementName isEqualToString:@"item"]) {
        self.torrent = [[NSMutableDictionary alloc] init];
    }
    
    self.elementBeingParced = elementName;
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([self.elementBeingParced isEqualToString:@"title"]) {
        self.torrent[@"title"] = string;
    }
    if ([self.elementBeingParced isEqualToString:@"link"] && !self.torrent[@"link"]) {
        self.torrent[@"link"] = string;
    } else if ([self.elementBeingParced isEqualToString:@"link"] && self.torrent[@"link"]){
        self.torrent[@"link"] = [NSString stringWithFormat:@"%@%@", self.torrent[@"link"], string];
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
        });
        
    }
}

@end
