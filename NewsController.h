//
//  NewsController.h
//  bitspace-iphone
//
//  Created by Fredrik Lundqvist on 11/9/10.
//  Copyright 2010 Sutajio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"

@class AppDelegate;
//@class NewsItemController;

@interface NewsController : PullToRefreshTableViewController <UITableViewDataSource, UITableViewDelegate> {
	AppDelegate *appDelegate;
	IBOutlet UINavigationBar *navigationBar;
	
	NSMutableArray *newsItems;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, readonly) UINavigationBar *navigationBar;

@property (nonatomic, retain) NSMutableArray *newsItems;

- (NSString *)saveFilePath;

@end
