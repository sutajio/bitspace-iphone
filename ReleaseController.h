//
//  ReleaseController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate, Release, ReleaseLoader;

@interface ReleaseController : UITableViewController {
	AppDelegate *appDelegate;
	Release *release;
	NSMutableArray *tracks;
	
	UIView *tableHeaderView;
	UIImageView *artworkImage;
	UIActivityIndicatorView *activityIndicator;
	
	NSOperationQueue *operationQueue;
	ReleaseLoader *releaseLoader;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) Release *release;
@property (nonatomic, retain) NSMutableArray *tracks;

@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;
@property (nonatomic, retain) IBOutlet UIImageView *artworkImage;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, retain, readonly) ReleaseLoader *releaseLoader;

@end
