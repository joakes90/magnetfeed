//
//  Source.h
//  Magnet Feed
//
//  Created by Justin Oakes on 6/22/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Torrent;

@interface Source : NSManagedObject

+ (NSString *) entityName;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSDate *dateAdded;
@property (nonatomic, retain) NSSet *torrent;
@end

@interface Source (CoreDataGeneratedAccessors)

- (void)addTorrentObject:(Torrent *)value;
- (void)removeTorrentObject:(Torrent *)value;
- (void)addTorrent:(NSSet *)values;
- (void)removeTorrent:(NSSet *)values;

@end
