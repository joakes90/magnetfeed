//
//  Source.m
//  Magnet Feed
//
//  Created by Justin Oakes on 6/22/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import "Source.h"
#import "Torrent.h"


@implementation Source

static NSString * entityName;
+ (nonnull NSString *) entityName {
    return @"Source";
}
@dynamic url;
@dynamic torrent;
@dynamic dateAdded;
@end
