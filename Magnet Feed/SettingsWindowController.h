//
//  SettingsWindowController.h
//  Magnet Feed
//
//  Created by Justin Oakes on 6/20/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SettingsWindowController : NSWindowController

@property (strong) IBOutlet NSWindow *settingsWindow;

typedef enum RefreshInterval: NSUInteger {
    k5min,
    k30min,
    k60min,
    kNA
} RefreshInterval;

@end
