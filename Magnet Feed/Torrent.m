//
//  Torrent.m
//  Magnet Feed
//
//  Created by Justin Oakes on 6/22/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import "Torrent.h"
#import "Source.h"


@implementation Torrent

@dynamic date;
@dynamic link;
@dynamic name;
@dynamic source;
@dynamic reported;

+ (NSString *) entityName {
    return @"Torrent";
}

@end
