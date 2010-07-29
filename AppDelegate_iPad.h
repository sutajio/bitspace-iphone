//
//  AppDelegate_iPad.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-25.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@class LibraryController, BrowserController;


@interface AppDelegate_iPad : AppDelegate {
	UISplitViewController *splitViewController;
	LibraryController *libraryController;
}

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet LibraryController *libraryController;
@property (nonatomic, readonly) BrowserController *browserController;


@end
