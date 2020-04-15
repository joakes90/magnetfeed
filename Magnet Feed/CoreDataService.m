//
//  Stack.m
//
//  Created by Joshua Howland on 6/12/14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//

#import "CoreDataService.h"

@interface CoreDataService ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation CoreDataService

+ (CoreDataService *)sharedInstance {
    static CoreDataService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CoreDataService alloc] init];
    });
    return sharedInstance;
    
}

- (id)init {
    self = [super init];
    if (self) {
        [self setupManagedObjectContext];
    }
    return self;
}

- (void)setupManagedObjectContext
{
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSError* error;
    [self.managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                       configuration:nil
                                                                                 URL:self.storeURL
                                                                             options:nil
                                                                               error:&error];
    if (error) {
        NSLog(@"error: %@", error);
    }
    
    self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
}

- (NSURL*)storeURL
{
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[[@"~/Library/Application Support/MagnetFeed" stringByExpandingTildeInPath] stringByStandardizingPath]  isDirectory:nil];
    
    if (!fileExists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[@"~/Library/Application Support/MagnetFeed" stringByStandardizingPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //chang documents later
    NSURL* documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];

    return [documentsDirectory URLByAppendingPathComponent:@"MagnetFeed/db.sqlite"];
}

- (NSURL*)modelURL
{
    return [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
}

- (NSManagedObjectModel*)managedObjectModel
{
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
}

@end
