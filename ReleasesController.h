//
//  ReleasesController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-03-31.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReleasesLoader.h"
#import "ReleaseLoader.h"

@class AppDelegate;

@interface ReleasesController : UITableViewController <ReleasesLoaderDelegate, ReleaseLoaderDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
	AppDelegate *appDelegate;
	NSFetchedResultsController *fetchedResultsController;
	NSOperationQueue *operationQueue;
	ReleasesLoader *loader;
	
	IBOutlet UINavigationBar *navigationBar;
	
	UISearchBar *searchBar;
	UISearchDisplayController *searchController;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, retain, readonly) ReleasesLoader *loader;

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UISearchDisplayController *searchController;

@end
