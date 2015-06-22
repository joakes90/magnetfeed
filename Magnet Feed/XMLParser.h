//
//  XMLParser.h
//  Magnet Feed
//
//  Created by Justin Oakes on 6/20/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Source.h"

@interface XMLParser : NSObject <NSXMLParserDelegate>

+ (instancetype) sharedInstance;

-(void)parseWithSource:(Source *)source;

@end
