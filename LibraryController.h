//
//  LibraryController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-28.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface LibraryController : UITableViewController {
	AppDelegate *appDelegate;
	NSArray *playlists;
}

@property (nonatomic, retain) AppDelegate *appDelegate;

@end
