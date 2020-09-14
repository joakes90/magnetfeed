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

@property NSArray *sources;

@property (strong) IBOutlet NSPanel *addFeedWindow;

@property (strong) IBOutlet NSMatrix *autoDownloadMatrix;

@end

@implementation SettingsWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    self.sources = [TorrentService shared].sources;
    [self.tableView reloadData];
    
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

//- (BOOL)verifyURLisFeed:(NSURL *)url {
//    NSXMLParser *testParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
//    return [testParser parse];
//}

//- (IBAction)matrixChangedStates:(id)sender {
//    if (self.autoDownloadMatrix.selectedColumn == 0) {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"autoDownload"];
//    }else{
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"autoDownload"];
//    }
//}

@end
