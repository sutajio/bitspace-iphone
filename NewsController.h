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

@interface NewsController : PullToRefreshTableViewController <UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate> {
	AppDelegate *appDelegate;
	IBOutlet UINavigationBar *navigationBar;
	
	//NewsItemController *newsItemViewController;
	NSMutableArray *savedNewsList;
	NSMutableArray *newsList;
	NSMutableDictionary *newsItem;
	NSMutableString *currentElementValue;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, readonly) UINavigationBar *navigationBar;

//@property (nonatomic, retain) NewsItemController *newsItemController;
@property (nonatomic, retain) NSMutableArray *savedNewsList;
@property (nonatomic, retain) NSMutableArray *newsList;
@property (nonatomic, retain) NSMutableDictionary *newsItem;

- (NSString *)saveFilePath;

@end
