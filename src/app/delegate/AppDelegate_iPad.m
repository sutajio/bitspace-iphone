//
//  AppDelegate_iPad.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-25.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "AppDelegate_iPad.h"


@implementation AppDelegate_iPad

@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:navigationController.view];
	
	// Call the super class
	[super applicationDidFinishLaunching:application];
	
	// Show the application window
	[window makeKeyAndVisible];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [super dealloc];
}


@end
