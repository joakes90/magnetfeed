//
//  Torrent.h
//  Magnet Feed
//
//  Created by Justin Oakes on 6/22/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Source;

@interface Torrent : NSManagedObject

+ (NSString *) entityName;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Source *source;
@property (nonatomic) BOOL reported;

@end
