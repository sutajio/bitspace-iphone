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

@interface FavoritesController : PullToRefreshTableViewController <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
	AppDelegate *appDelegate;
	NSFetchedResultsController *fetchedResultsController;
	NSFetchedResultsController *searchResultsController;
	
	IBOutlet UINavigationBar *navigationBar;
	IBOutlet UIView *tableHeaderView;
	IBOutlet UISearchBar *searchBar;
	UISearchDisplayController *searchController;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *searchResultsController;

@property (nonatomic, readonly) UINavigationBar *navigationBar;

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UISearchDisplayController *searchController;

- (void)resetView;

- (IBAction)playAllTracks:(id)sender;
- (IBAction)shuffleAllTracks:(id)sender;

@end
