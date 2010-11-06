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
//@class NewsItemViewController;

@interface NewsController : PullToRefreshTableViewController <UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate> {
	AppDelegate *appDelegate;
	IBOutlet UINavigationBar *navigationBar;
	
	//NewsItemViewController *newsItemViewController;
	NSMutableArray *savedNewsList;
	NSMutableArray *newsList;
	NSMutableDictionary *newsItem;
	NSMutableString *currentElementValue;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, readonly) UINavigationBar *navigationBar;

//@property (nonatomic, retain) NewsItemViewController *newsItemViewController;
@property (nonatomic, retain) NSMutableArray *savedNewsList;
@property (nonatomic, retain) NSMutableArray *newsList;
@property (nonatomic, retain) NSMutableDictionary *newsItem;

- (NSString *)saveFilePath;

@end
