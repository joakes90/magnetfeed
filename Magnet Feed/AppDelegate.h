//
//  AppDelegate.h
//  Magnet Feed
//
//  Created by Justin Oakes on 6/20/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSViewController *addSourceView;

@property (strong, nonatomic) NSWindowController *addSourceWindow;

@property (strong, nonatomic) NSTimer *refreshTimer;

- (void) configureTimerWithInterval:(NSInteger)interval;

@end

