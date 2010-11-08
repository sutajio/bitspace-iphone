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


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:splitViewController.view];
	
	// Call the super class
	[super application:application didFinishLaunchingWithOptions:launchOptions];
	
	// Pass self to the controllers
	libraryController.appDelegate = self;
	
	// Show the application window
	[window makeKeyAndVisible];
	
	return YES;
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
