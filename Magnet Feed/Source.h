//
//  Source.h
//  Magnet Feed
//
//  Created by Justin Oakes on 6/20/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Torrent;

@interface Source : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *torrent;
@end

@interface Source (CoreDataGeneratedAccessors)

- (void)addTorrentObject:(Torrent *)value;
- (void)removeTorrentObject:(Torrent *)value;
- (void)addTorrent:(NSSet *)values;
- (void)removeTorrent:(NSSet *)values;

@end
