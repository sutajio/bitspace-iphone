//
//  FavoritesController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-08.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"

@class AppDelegate;

@interface FavoritesController : PullToRefreshTableViewController <NSFetchedResultsControllerDelegate> {
	AppDelegate *appDelegate;
	NSFetchedResultsController *fetchedResultsController;
	
	IBOutlet UINavigationBar *navigationBar;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, readonly) UINavigationBar *navigationBar;

- (void)resetView;

@end
