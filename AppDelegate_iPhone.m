//
//  AppDelegate_iPhone.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-25.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "ArtistsController.h"
#import "ReleasesController.h"
#import "FavoritesController.h"
#import "SignInController.h"


@implementation AppDelegate_iPhone

@synthesize tabBarController;
@synthesize artistsController;
@synthesize releasesController;
@synthesize favoritesController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:tabBarController.view];
	
	// Call the super class
	[super applicationDidFinishLaunching:application];
	
	// Pass self to the controllers
	artistsController.appDelegate = self;
	releasesController.appDelegate = self;
	favoritesController.appDelegate = self;
	
	// Show the application window
	[window makeKeyAndVisible];
	
	// Select the correct tab if user has used the app before
	self.tabBarController.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"TabBarSelectedIndex"];
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	
	// Save which tab the user has selected
	[[NSUserDefaults standardUserDefaults] setInteger:self.tabBarController.selectedIndex forKey:@"TabBarSelectedIndex"];
}


- (void)requestAuthenticationFromUser {
	
	// Show sign in screen
	SignInController *signInController = [[SignInController alloc] init];
	signInController.appDelegate = self;
	signInController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self.tabBarController presentModalViewController:signInController animated:YES];
	[signInController release];
}


- (void)resetUI {
	
	// Reset all views
	[self.artistsController resetView];
	[self.releasesController resetView];
	[self.favoritesController resetView];
}


- (void)showPlayer {
	self.tabBarController.selectedViewController = (UIViewController *)self.playerController;
}


- (void)dealloc {
	[tabBarController release];
    [super dealloc];
}


@end
