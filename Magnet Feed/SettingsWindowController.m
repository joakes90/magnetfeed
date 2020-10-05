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

@property (weak) IBOutlet NSButton *autoDownloadEnabledButton;

@property (weak) IBOutlet NSPopUpButton *refreshPopup;

@property (weak) AppDelegate *appDelegate;

@property BOOL autoDownloadEnabled;

@property NSArray *sources;

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(configureRefreshPopUp)
                                                 name:@"refreshIntervalChanged"
                                               object:nil];
    [self configureRefreshPopUp];
    _autoDownloadEnabled = [[UserDefaultService getValueFor:UserDefaultKeyAutoDownload] boolValue];
    [self configureRadioButtons];
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
    NSInteger timeInterval;
    switch (interval) {
        case k5min:
            timeInterval = 5 * 60;
            break;
        case k30min:
            timeInterval = 30 * 60;
            break;
        case k60min:
            timeInterval = 60 * 60;
            break;
        case kNA:
            timeInterval = -1;
            break;
        default:
            return;
    }
    [appDelegate configureTimerWithInterval:timeInterval];
}

- (void)sourceListDidUpdate {
    self.sources = [TorrentService shared].sources;
    [self.tableView reloadData];
}

- (void) configureRefreshPopUp {
    UserDefaultKey key = UserDefaultKeyRefreshInterval;
    NSInteger timeInterval = [[UserDefaultService getValueFor:key] integerValue];
    NSInteger popupIndex;
    switch (timeInterval / 60) {
        case 5:
            popupIndex = 0;
            break;
        case 30:
            popupIndex = 1;
            break;
        case 60:
            popupIndex = 2;
            break;
        case -1:
            popupIndex = 3;
            break;
        default:
            popupIndex = 0;
            [_appDelegate configureTimerWithInterval:300];
            return;
    }
    [_refreshPopup selectItemAtIndex:popupIndex];
}

- (void) configureRadioButtons {
    NSControlStateValue state = _autoDownloadEnabled ? NSControlStateValueOn : NSControlStateValueOff;
    [_autoDownloadEnabledButton setState:state];
}

- (IBAction)matrixChangedStates:(id)sender {
    if (sender == _autoDownloadEnabledButton) {
        _autoDownloadEnabled = YES;
    } else {
        _autoDownloadEnabled = NO;
    }
    [UserDefaultService setValue:[NSNumber numberWithBool:_autoDownloadEnabled] for:UserDefaultKeyAutoDownload];
}

@end
