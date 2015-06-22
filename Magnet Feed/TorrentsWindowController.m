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

- (IBAction)downloadTorrent:(id)sender
{
    
}

@end
