//
//  AppDelegate.m
//  Magnet Feed
//
//  Created by Justin Oakes on 6/20/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import "AppDelegate.h"
#import "Magnet_Feed-Swift.h"
#import "SettingsWindowController.h"
#import "TorrentsWindowController.h"
#import "CoreDataService.h"
#import "Source.h"
#import "JTOXMLParser.h"


@interface AppDelegate ()

@property (strong, nonatomic) NSStatusItem *statusItem;

@property (strong, nonatomic) SettingsWindowController *settingsWindow;

@property (strong, nonatomic) TorrentsWindowController *torrentsWindow;

@property (weak) IBOutlet NSMenu *menu;

@property (strong, nonatomic) NSTimer *checkforUpdates;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[TorrentService shared] getNewTorrentsFrom:nil];

    // TODO: create a user manipulable timer
    self.checkforUpdates = [NSTimer scheduledTimerWithTimeInterval:1800 target:[TorrentService shared] selector:@selector(getNewTorrentsFrom:) userInfo:nil repeats:YES];
    [self seeDownloads];
    [self.torrentsWindow showWindow:self];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!flag) {
        [self seeDownloads];
    }
    return YES;
}

- (IBAction)openSettings:(id)sender {
    if (!self.settingsWindow.settingsWindow) {
        self.settingsWindow  = [[SettingsWindowController alloc] initWithWindowNibName:@"SettingsWindowController"];
        [self.settingsWindow showWindow:self];
    }
    [self.settingsWindow.settingsWindow makeKeyAndOrderFront:self];
}

- (void)seeDownloads {
    self.torrentsWindow = [[TorrentsWindowController alloc] initWithWindowNibName:@"TorrentsWindowController"];
    [self.torrentsWindow showWindow:self];
    [self.torrentsWindow.window orderFront:self];
}

- (IBAction)addFeed:(id)sender {
    if (self.addSourceView == nil) {
        self.addSourceView = [[AddSourceViewController alloc] initWithNibName:@"AddSourceView" bundle:nil];
    }
    [self.addSourceView presentViewControllerAsModalWindow:self.addSourceView];
}

- (IBAction)refreshTorrents:(id)sender {
    [[TorrentService shared] getNewTorrentsFrom:nil];
}

- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (void) configureTimerWithInterval:(NSInteger)interval {
    [self.refreshTimer invalidate];
    UserDefaultKey key = UserDefaultKeyRefreshInterval;
    [UserDefaultService setValue:[NSNumber numberWithInteger:(interval * 60)] for:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshIntervalChanged" object:nil];
    if (interval <= 0) {
        self.refreshTimer = nil;
        return;
    }
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                         target:self
                                                       selector:@selector(refreshTorrents:)
                                                       userInfo:nil repeats:YES];
    [self.refreshTimer fire];
}

@end
