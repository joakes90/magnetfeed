//
//  Stack.m
//
//  Created by Joshua Howland on 6/12/14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//


#import <Foundation/Foundation.h>
@import CoreData;

@interface CoreDataService : NSObject

+ (nonnull CoreDataService *)sharedInstance;

@property (nonatomic, strong, readonly) NSManagedObjectContext * _Nonnull managedObjectContext;

@end
