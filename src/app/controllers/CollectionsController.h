//
//  CollectionsController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2011-02-02.
//  Copyright 2011 Sutajio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTGridViewController.h"

@class AppDelegate;

@interface CollectionsController : DTGridViewController <NSFetchedResultsControllerDelegate> {
	AppDelegate *appDelegate;
	NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
