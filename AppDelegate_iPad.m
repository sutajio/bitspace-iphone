//
//  AppDelegate_iPad.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-25.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "AppDelegate_iPad.h"
#import "LibraryController.h"
#import "BrowserController.h"


@implementation AppDelegate_iPad

@synthesize splitViewController;
@synthesize libraryController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[super applicationDidFinishLaunching:application];
	
	// Pass self to the controllers
	libraryController.appDelegate = self;
	
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:splitViewController.view];
	[window makeKeyAndVisible];
}

- (BrowserController *)browserController {
	return (BrowserController *)self.playerController;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [super dealloc];
}


@end
