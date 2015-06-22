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

-(void) removeDuplicatesFromTorrentsArray {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Torrent"];
    NSArray *existingTorrents = [[Stack sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    for (NSMutableDictionary *newTorrent in self.arrayOfNewTorrents) {
        for (Torrent *oldTorrent in existingTorrents) {
            if ([oldTorrent.link isEqualToString:newTorrent[@"link"]]) {
                [self.arrayOfNewTorrents removeObject:newTorrent];
            }
        }
    }
}

#pragma mark NSXMLParserDelegate Methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"item"]) {
        self.torrent = [[NSMutableDictionary alloc] init];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([self.elementBeingParced isEqualToString:@"title"]) {
        self.torrent[@"title"] = string;
    }
    if ([self.elementBeingParced isEqualToString:@"link"]) {
        self.torrent[@"link"] = string;
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
        [self removeDuplicatesFromTorrentsArray];
    }
    if ([elementName isEqualToString:@"rss"]) {
        NSLog(@"%@", self.arrayOfNewTorrents);
    }
}

@end
