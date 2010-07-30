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

@interface AppDelegate_iPhone ()
- (void)animateArrowIndicatorToIndex:(int)index;
@end

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
	
	// Create the indicator image
	indicatorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
	[[tabBarController tabBar] addSubview:indicatorImage];
	
	// Select the correct tab if user has used the app before
	self.tabBarController.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"TabBarSelectedIndex"];
	[self animateArrowIndicatorToIndex:[self.tabBarController selectedIndex]];
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	
	// When we're about to select a view controller, animate the indicator arrow on to that item
	[self animateArrowIndicatorToIndex:[self.tabBarController selectedIndex]];
	
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
	[self animateArrowIndicatorToIndex:0];
}


/**
 *	Animate the Tweetie-like arrow indicator to a specific index
 */
- (void)animateArrowIndicatorToIndex:(int)index {
	// Get the total items in the tab bar
	int itemCount     = [[[tabBarController tabBar] items] count];
	// Only show the indicator if we have any items in the tab bar
	if(itemCount > 0) {
		// Find out how wide the individual cells are
		CGFloat cellWidth = [[tabBarController view] frame].size.width / itemCount;
		// Find the center point based on the cell width and the image widht
		CGFloat center = (index * cellWidth) + (cellWidth / 2) - ([indicatorImage frame].size.width/2);
		// Create a frame defining where the indicator image should be placed
		CGRect  frame = CGRectMake(center, -6, [indicatorImage frame].size.width, [indicatorImage frame].size.height);
		// Animate the image to the new position
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.25];
		[indicatorImage setFrame:frame];
		[UIView commitAnimations];
	} else {
		// If there are no items in the tab bar we don't show the indicator
		[indicatorImage removeFromSuperview];
	}
	
}


- (void)dealloc {
	[indicatorImage release];
	[tabBarController release];
	[super dealloc];
}


@end
