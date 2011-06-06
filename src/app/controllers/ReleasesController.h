//
//  ReleasesController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-03-31.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"
#import "SourcePickerController.h"

@class AppDelegate;

@interface ReleasesController : PullToRefreshTableViewController <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, PickerSheetProtocol> {
	AppDelegate *appDelegate;
	NSFetchedResultsController *fetchedResultsController;
	NSFetchedResultsController *searchResultsController;
	
    SourcePickerController *sourcePicker;
    NSString *source;
    
	IBOutlet UINavigationBar *navigationBar;
	IBOutlet UIView *tableHeaderView;
	IBOutlet UISearchBar *searchBar;
	UISearchDisplayController *searchController;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *searchResultsController;

@property (nonatomic, retain) NSString *source;

@property (nonatomic, readonly) UINavigationBar *navigationBar;

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UISearchDisplayController *searchController;

- (void)resetView;

- (IBAction)playAllTracks:(id)sender;
- (IBAction)shuffleAllTracks:(id)sender;

@end
