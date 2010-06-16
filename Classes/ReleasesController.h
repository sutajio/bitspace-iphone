//
//  ReleasesController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-03-31.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReleasesLoader.h"

@interface ReleasesController : UITableViewController <ReleasesLoaderDelegate, NSFetchedResultsControllerDelegate> {
	NSString *siteURL;
	NSString *username;
	NSString *password;
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	NSOperationQueue *operationQueue;
	ReleasesLoader *loader;
}

@property (nonatomic, retain) NSString *siteURL;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, retain, readonly) ReleasesLoader *loader;

- (void)refresh;
- (void)fetch;

@end
