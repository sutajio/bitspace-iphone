//
//  ReleasesController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-03-31.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"
#import "ReleasesLoader.h"
#import "ReleaseLoader.h"

@class AppDelegate;

@interface ReleasesController : PullToRefreshTableViewController <ReleasesLoaderDelegate, ReleaseLoaderDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
	AppDelegate *appDelegate;
	NSFetchedResultsController *fetchedResultsController;
	NSFetchedResultsController *searchResultsController;
	NSOperationQueue *operationQueue;
	ReleasesLoader *loader;
	
	IBOutlet UINavigationBar *navigationBar;
	
	UISearchBar *searchBar;
	UISearchDisplayController *searchController;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *searchResultsController;
@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, retain, readonly) ReleasesLoader *loader;

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UISearchDisplayController *searchController;

- (void)resetDataStoreAndView;

@end
