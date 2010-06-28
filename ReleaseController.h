//
//  ReleaseController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReleaseLoader.h"

@class AppDelegate, Release, ReleaseLoader, ReleaseLoaderDelegate;

@interface ReleaseController : UITableViewController <ReleaseLoaderDelegate, NSFetchedResultsControllerDelegate> {
	AppDelegate *appDelegate;
	Release *theRelease;
	NSFetchedResultsController *fetchedResultsController;
	
	UIView *tableHeaderView;
	
	NSOperationQueue *operationQueue;
	ReleaseLoader *releaseLoader;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) Release *theRelease;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;

@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, retain, readonly) ReleaseLoader *releaseLoader;

@end
