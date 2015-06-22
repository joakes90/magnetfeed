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
#import "Stack.h"
#import "Source.h"
#import "XMLParser.h"


@interface AppDelegate ()

@property (strong, nonatomic) NSStatusItem *statusItem;

@property (strong, nonatomic) SettingsWindowController *settingsWindow;

@property (strong, nonatomic) TorrentsWindowController *torrentsWindow;

@property (weak) IBOutlet NSMenu *menu;

@property (strong, nonatomic) NSTimer *checkforUpdates;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:-1.0];
    self.statusItem.title = @"temp text";
    self.statusItem.menu = self.menu;
    
    [self getNewTorrents];
    
    self.checkforUpdates = [NSTimer scheduledTimerWithTimeInterval:1800 target:self selector:@selector(checkforUpdates) userInfo:nil repeats:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)openSettings:(id)sender {
   self.settingsWindow  = [[SettingsWindowController alloc] initWithWindowNibName:@"SettingsWindowController"];
    [self.settingsWindow showWindow:self];
    
}

- (IBAction)seeDownloads:(id)sender {
    self.torrentsWindow = [[TorrentsWindowController alloc] initWithWindowNibName:@"TorrentsWindowController"];
    [self.torrentsWindow showWindow:self];
    [self.torrentsWindow.window orderFront:self];
}

-(void)getNewTorrents {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Source"];
    NSArray *sources = [[Stack sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    for (Source *source in sources) {
        [[XMLParser sharedInstance] parseWithSource:source];
    }
}
@end
