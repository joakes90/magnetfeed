//
//  TorrentsWindowController.m
//  Magnet Feed
//
//  Created by Justin Oakes on 6/21/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import "TorrentsWindowController.h"
#import "Torrent.h"
#import "Stack.h"

@interface TorrentsWindowController () <NSTableViewDataSource, NSTableViewDelegate>

@property (strong) IBOutlet NSTableView *tableView;

@property (strong, nonatomic) NSArray *torrentArray;

@end

@implementation TorrentsWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window = self.downloadsWindow;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Torrent"];
    NSMutableArray *torrentArray = [[[Stack sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    NSSortDescriptor *sortDescripter = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSArray *sortDescripters = [NSArray arrayWithObject:sortDescripter];
   self.torrentArray = [torrentArray sortedArrayUsingDescriptors:sortDescripters];
}

- (IBAction)downloadTorrent:(id)sender {
    NSInteger row = [self.tableView rowForView:sender];
    Torrent *torrent = self.torrentArray[row];
    NSURL *torrentURL = [NSURL URLWithString:torrent.link];
    
    [[NSWorkspace sharedWorkspace] openURL:torrentURL];
}


#pragma mark Tableview Datasource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.torrentArray.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell" owner:self];
    Torrent *torrent = self.torrentArray[row];
    [cell.textField setStringValue:torrent.name];
    return cell;
}
@end
