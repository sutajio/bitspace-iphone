//
//  ArtistsController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-13.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"

@class AppDelegate;

@interface ArtistsController : PullToRefreshTableViewController <NSFetchedResultsControllerDelegate> {
	AppDelegate *appDelegate;
	NSFetchedResultsController *fetchedResultsController;
	
	IBOutlet UINavigationBar *navigationBar;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, readonly) UINavigationBar *navigationBar;

- (void)resetView;

@end
