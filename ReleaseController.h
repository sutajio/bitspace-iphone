//
//  ReleaseController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate, Release;

@interface ReleaseController : UITableViewController <NSFetchedResultsControllerDelegate> {
	AppDelegate *appDelegate;
	Release *theRelease;
	NSFetchedResultsController *fetchedResultsController;
	
	UIView *tableHeaderView;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) Release *theRelease;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;

@end
