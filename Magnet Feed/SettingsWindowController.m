//
//  SettingsWindowController.m
//  Magnet Feed
//
//  Created by Justin Oakes on 6/20/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import "AppDelegate.h"
#import "Magnet_Feed-Swift.h"
#import "SettingsWindowController.h"
#import "Source.h"
#import "CoreDataService.h"
#import "JTOXMLParser.h"

@interface SettingsWindowController () <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *tableView;

@property (strong) IBOutlet NSTextField *urlTextField;

@property (weak) AppDelegate *appDelegate;

@property NSArray *sources;

@property (strong) IBOutlet NSPanel *addFeedWindow;

@property (strong) IBOutlet NSMatrix *autoDownloadMatrix;

@property (weak) IBOutlet NSPopUpButton *refreshPopup;

@end

@implementation SettingsWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.appDelegate = [NSApplication sharedApplication].delegate;
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self sourceListDidUpdate];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(sourceListDidUpdate)
                                                 name:@"sourceListUpdated"
                                               object:nil];
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoDownload"]) {
//        [self.autoDownloadMatrix selectCellAtRow:0 column:0];
//    } else {
//        [self.autoDownloadMatrix selectCellAtRow:0 column:1];
//
//    }
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.sources.count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    Source *source = self.sources[row];
    return source.url;
}

- (IBAction)removeSource:(id)sender {
    NSInteger selectedRow = [self.tableView selectedRow];
    if (selectedRow >= 0) {
        [[CoreDataService sharedInstance].managedObjectContext deleteObject:[self.sources objectAtIndex:selectedRow]];
        [[CoreDataService sharedInstance].managedObjectContext save:nil];
        NSNotification *notification = [[NSNotification alloc] initWithName:@"torrentUpdateComplete"
                                                                     object:nil
                                                                   userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        NSUInteger newSelection = selectedRow - 1;
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newSelection] byExtendingSelection:NO];
        [self.tableView reloadData];
    }
}

- (IBAction)addSource:(id)sender {
    if (!_appDelegate.addSourceView) {
        _appDelegate.addSourceView = [[AddSourceViewController alloc] initWithNibName:@"AddSourceView" bundle:nil];
        NSWindow *addSourceWindow = [NSWindow windowWithContentViewController:_appDelegate.addSourceView];
        NSWindowController *addSourceWindowController = [[NSWindowController alloc] initWithWindow:addSourceWindow];
        _appDelegate.addSourceWindow = addSourceWindowController;
    }
    [_appDelegate.addSourceWindow showWindow:_appDelegate.addSourceWindow.window];
    [_appDelegate.addSourceWindow.window makeKeyAndOrderFront:_appDelegate.addSourceWindow.window];
}

- (IBAction)refreshPopupChanged:(id)sender {
    AppDelegate *appDelegate = [NSApplication sharedApplication].delegate;
    RefreshInterval interval = self.refreshPopup.indexOfSelectedItem;
    switch (interval) {
        case k5min:
            [appDelegate configureTimerWithInterval: (5 * 60)];
            break;
        case k30min:
            [appDelegate configureTimerWithInterval: (30 * 60)];
            break;
        case k60min:
            [appDelegate configureTimerWithInterval: (60 * 60)];
            break;
        case kNA:
            [appDelegate configureTimerWithInterval:-1];
            break;
        default:
            return;
    }
}

- (void)sourceListDidUpdate {
    self.sources = [TorrentService shared].sources;
    [self.tableView reloadData];
}

//- (IBAction)matrixChangedStates:(id)sender {
//    if (self.autoDownloadMatrix.selectedColumn == 0) {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"autoDownload"];
//    }else{
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"autoDownload"];
//    }
//}

@end
