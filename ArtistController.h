//
//  ArtistController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-15.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate, Artist;

@interface ArtistController : UITableViewController <NSFetchedResultsControllerDelegate> {
	AppDelegate *appDelegate;
	Artist *theArtist;
	NSFetchedResultsController *fetchedResultsController;
	
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) Artist *theArtist;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
