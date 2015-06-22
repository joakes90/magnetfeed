//
//  TorrentsWindowController.m
//  Magnet Feed
//
//  Created by Justin Oakes on 6/21/15.
//  Copyright (c) 2015 Oklasoft. All rights reserved.
//

#import "TorrentsWindowController.h"

@interface TorrentsWindowController ()

@end

@implementation TorrentsWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window = self.downloadsWindow;
}

- (IBAction)downloadTorrent:(id)sender {
}

@end
