//
//  AppDelegate.m
//  Magnet Feed
//
//  Created by Justin Oakes on 6/20/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import "AppDelegate.h"
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
    [self getNewTorrents];
    // TODO: create a user manipulable timer
    self.checkforUpdates = [NSTimer scheduledTimerWithTimeInterval:1800 target:self selector:@selector(getNewTorrents) userInfo:nil repeats:YES];
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
   self.settingsWindow  = [[SettingsWindowController alloc] initWithWindowNibName:@"SettingsWindowController"];
    [self.settingsWindow showWindow:self];
    
}

- (void)seeDownloads {
    self.torrentsWindow = [[TorrentsWindowController alloc] initWithWindowNibName:@"TorrentsWindowController"];
    [self.torrentsWindow showWindow:self];
    [self.torrentsWindow.window orderFront:self];
}

-(void)getNewTorrents {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Source"];
    NSArray *sources = [[CoreDataService sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if (sources.count == 0) {
        // TODO: Create central place to make this call
        NSNotification *notification = [[NSNotification alloc] initWithName:@"torrentUpdate"
                                                                     object:nil
                                                                   userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        return;
    }
    for (Source *source in sources) {
        [[JTOXMLParser sharedInstance] parseWithSource:source];
    }
}

- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}
@end
