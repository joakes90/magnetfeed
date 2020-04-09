//
//  SettingsWindowController.m
//  Magnet Feed
//
//  Created by Justin Oakes on 6/20/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import "SettingsWindowController.h"
#import "Stack.h"
#import "Source.h"
#import "AppDelegate.h"

@interface SettingsWindowController () <NSTableViewDataSource, NSTableViewDelegate>


@property (strong) IBOutlet NSTableView *tableView;

@property (strong) IBOutlet NSPanel *SettingsWindow;

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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Source"];
    self.sources = [[Stack sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    [self.tableView reloadData];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoDownload"]) {
        [self.autoDownloadMatrix selectCellAtRow:0 column:0];
    } else {
        [self.autoDownloadMatrix selectCellAtRow:0 column:1];
        
    }
}


-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.sources.count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    Source *source = self.sources[row];
    return source.url;
}

- (IBAction)addSource:(id)sender {
    NSString *urlString = self.urlTextField.stringValue;
    if ([self verifyURLisFeed:[NSURL URLWithString:urlString]]) {
        BOOL duplicate = NO;
        for (Source *source in self.sources) {
            if ([source.url isEqualToString:urlString]) {
                duplicate = YES;
            }
        }
        
        if (!duplicate) {
            Source *newSource = [NSEntityDescription insertNewObjectForEntityForName:@"Source" inManagedObjectContext:[Stack sharedInstance].managedObjectContext];
            newSource.url = urlString;
            [[Stack sharedInstance].managedObjectContext save:nil];
            self.sources = [[Stack sharedInstance].managedObjectContext executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Source"] error:nil];
            AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
            [appDelegate getNewTorrents];
        } else {
            // TODO: Tell the user that feed already exists
        }
        [self.tableView reloadData];
        [self.addFeedWindow close];
    }
}


- (IBAction)removeSelectedFeed:(id)sender {
    [[Stack sharedInstance].managedObjectContext deleteObject:[self.sources objectAtIndex:[self.tableView selectedRow]]];
    [[Stack sharedInstance].managedObjectContext save:nil];
    [self.tableView reloadData];
}

- (BOOL)verifyURLisFeed:(NSURL *)url {
    NSXMLParser *testParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    return [testParser parse];
}

- (IBAction)matrixChangedStates:(id)sender {
    if (self.autoDownloadMatrix.selectedColumn == 0) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"autoDownload"];
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"autoDownload"];
    }
}

@end
