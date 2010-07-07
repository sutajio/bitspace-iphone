//
//  ReleaseController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate, Release;

@interface ReleaseController : UITableViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate> {
	AppDelegate *appDelegate;
	Release *theRelease;
	NSFetchedResultsController *fetchedResultsController;
	
	UIView *tableHeaderView;
	IBOutlet UIImageView *artworkImage;
	IBOutlet UILabel *artistLabel;
	IBOutlet UILabel *titleLabel;
	
	UIView *tableFooterView;
	IBOutlet UILabel *releasedAtLabel;
	IBOutlet UILabel *releasedByLabel;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) Release *theRelease;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) UIView *tableHeaderView;
@property (nonatomic, retain) UIImageView *artworkImage;
@property (nonatomic, retain) UILabel *artistLabel;
@property (nonatomic, retain) UILabel *titleLabel;

@property (nonatomic, retain) UIView *tableFooterView;
@property (nonatomic, retain) UILabel *releasedAtLabel;
@property (nonatomic, retain) UILabel *releasedByLabel;

- (IBAction)offline:(id)sender;
- (IBAction)shuffle:(id)sender;

@end
