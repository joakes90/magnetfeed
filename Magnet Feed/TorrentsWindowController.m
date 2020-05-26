//
//  TorrentsWindowController.m
//  Magnet Feed
//
//  Created by Justin Oakes on 6/21/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import "AppDelegate.h"
#import "Magnet_Feed-Swift.h"
#import "CoreDataService.h"
#import "TorrentsWindowController.h"
#import "Torrent.h"

@interface TorrentsWindowController () <NSTableViewDataSource, NSTableViewDelegate>

@property (strong) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSScrollView *tableViewContainer;
@property (weak) IBOutlet NSToolbarItem *addFeedButton;
@property (weak) IBOutlet NSToolbarItem *refreshTorrentsButton;
@property (strong, nonatomic) NSArray *torrentArray;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *infoLabel;


@end

@implementation TorrentsWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window = self.downloadsWindow;
    [self.infoLabel setAttributedStringValue:[self getAttributedInfoText]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(torrentsDidUpdate)
                                                 name:@"torrentUpdate" object:nil];
    
    self.torrentArray = [self fetchTorrents];
    [self.tableView reloadData];
}

- (NSArray *)fetchTorrents {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Torrent"];
    NSError *error;
    NSMutableArray *torrentArray = [[[CoreDataService sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    NSSortDescriptor *sortDescripter = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSArray *sortDescripters = [NSArray arrayWithObject:sortDescripter];
    return [torrentArray sortedArrayUsingDescriptors:sortDescripters];
}
- (IBAction)downloadTorrent:(id)sender {
    NSInteger row = [self.tableView rowForView:sender];
    Torrent *torrent = self.torrentArray[row];
    NSURL *torrentURL = [NSURL URLWithString:torrent.link];
    
    [[NSWorkspace sharedWorkspace] openURL:torrentURL];
}

- (void)torrentsDidUpdate {
    self.torrentArray = [self fetchTorrents];
    [self.progressIndicator stopAnimation:self];
    [self.progressIndicator setHidden:YES];
    [self.tableView reloadData];
}

- (NSAttributedString *) getAttributedInfoText {
    NSString *localizedString = NSLocalizedString(@"Add a feed to get started. \nGo to https://showrss.info to learn more.",
                                                  @"See showrss.info label text");
    NSRange linkRange = [localizedString rangeOfString:@"https://showrss.info"];
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:localizedString];
    [attributedString addAttributes:@{NSForegroundColorAttributeName: [NSColor systemBlueColor],
                                      NSUnderlineStyleAttributeName: @1}
                              range: linkRange];
    [attributedString addAttributes:@{NSParagraphStyleAttributeName: paragraphStyle} range: NSMakeRange(0, attributedString.length)];
    
    return attributedString;
}

#pragma mark IBActions
- (IBAction)addFeedWasClicked:(id)sender {
    // Initalize view and popover
    NSViewController *addSourceViewController = [[AddSourceView alloc] initWithNibName:@"AddSourceView" bundle:nil];
    NSPopover *addSourcePopover = [[NSPopover alloc] init];
    
    // Configure popover
    [addSourcePopover setContentSize:NSMakeSize(350.0, 115.0)];
    [addSourcePopover setBehavior:NSPopoverBehaviorTransient];
    [addSourcePopover setAnimates:YES];
    [addSourcePopover setContentViewController:addSourceViewController];
    
    NSRect buttonRect = [sender convertRect:self.addFeedButton.view.bounds toView:self.contentViewController.view];
    [addSourcePopover showRelativeToRect:buttonRect ofView:self.window.contentView preferredEdge:NSMinYEdge];
}

- (IBAction)refreshWasClicked:(id)sender {
    [self.progressIndicator setHidden:NO];
    [self.progressIndicator startAnimation:self];
    [[SourceService shared] getNewTorrentsFrom:nil];
}

- (IBAction)infoLabelWasClicked:(id)sender {
    NSURL *showRssUrl = [[NSURL alloc] initWithString:@"https://showrss.info"];
    [[NSWorkspace sharedWorkspace] openURL:showRssUrl];
}

#pragma mark Tableview Datasource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger rows = self.torrentArray.count;
    [self.tableViewContainer setHidden:(rows == 0)];
    return rows;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell" owner:self];
    Torrent *torrent = self.torrentArray[row];
    [cell.textField setStringValue:torrent.name];
    return cell;
}
@end
