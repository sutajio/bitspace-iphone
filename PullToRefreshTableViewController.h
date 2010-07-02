//
//  PullToRefreshTableViewController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-02.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshTableHeaderView.h"

@interface PullToRefreshTableViewController : UITableViewController
{
	RefreshTableHeaderView *refreshHeaderView;
	
	BOOL checkForRefresh;
	BOOL reloading;
}

- (void)dataSourceDidFinishLoadingNewData;
- (void)showReloadAnimationAnimated:(BOOL)animated;

@end
