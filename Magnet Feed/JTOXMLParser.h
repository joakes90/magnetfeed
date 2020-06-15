//
//  XMLParser.h
//  Magnet Feed
//
//  Created by Justin Oakes on 6/20/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Source.h"

@interface JTOXMLParser : NSObject <NSXMLParserDelegate>

+ (instancetype _Nonnull ) sharedInstance;

+ (void) validateURLIsFeed:(NSURL *_Nullable)url withCompletion: ( void ( ^_Nonnull ) ( NSError * _Nullable error, BOOL success) )completion;

- (void)parseWithSource:(Source *_Nonnull)source;
@end
