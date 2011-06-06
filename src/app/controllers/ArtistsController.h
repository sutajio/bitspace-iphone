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

@interface ArtistsController : PullToRefreshTableViewController <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
	AppDelegate *appDelegate;
	NSFetchedResultsController *fetchedResultsController;
	NSFetchedResultsController *searchResultsController;
	
	IBOutlet UINavigationBar *navigationBar;
	
	UISearchBar *searchBar;
	UISearchDisplayController *searchController;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *searchResultsController;

@property (nonatomic, readonly) UINavigationBar *navigationBar;

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UISearchDisplayController *searchController;

- (void)resetView;

@end
