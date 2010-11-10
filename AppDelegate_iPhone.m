//
//  AppDelegate_iPhone.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-25.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "ReleasesController.h"
#import "NewsController.h"

@interface AppDelegate_iPhone ()
- (void)animateArrowIndicatorToIndex:(int)index;
@end

@implementation AppDelegate_iPhone

@synthesize tabBarController;
@synthesize releasesController;
@synthesize favoritesController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:tabBarController.view];
	
	// Call the super class
	[super application:application didFinishLaunchingWithOptions:launchOptions];
	
	// Pass self to the controllers
	releasesController.appDelegate = self;
	favoritesController.appDelegate = self;
	
	// Show the application window
	[window makeKeyAndVisible];
	
	// Create the indicator image
	indicatorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
	[[tabBarController tabBar] addSubview:indicatorImage];
	
	// Select the correct tab if user has used the app before, or if a remote notification is being handled
	if([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
		self.tabBarController.selectedIndex = 1;
		[self animateArrowIndicatorToIndex:[self.tabBarController selectedIndex]];
	} else {
		if([[NSUserDefaults standardUserDefaults] integerForKey:@"TabBarSelectedIndex"]) {
			self.tabBarController.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"TabBarSelectedIndex"];
		} else {
			self.tabBarController.selectedIndex = 1;
		}
		[self animateArrowIndicatorToIndex:[self.tabBarController selectedIndex]];
	}
	
	return YES;
}


- (void)releasesTabBarItemBadgeValue:(NSString *)value {
	UITabBarItem *tabBarItem = (UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:1];
	if (tabBarItem) {
		tabBarItem.badgeValue = value;
	}
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	[super application:application didReceiveRemoteNotification:userInfo];
	if (self.tabBarController.selectedIndex != 1) {
		if ([userInfo objectForKey:@"aps"] && [[userInfo objectForKey:@"aps"] objectForKey:@"badge"]) {
			[self releasesTabBarItemBadgeValue:[[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] stringValue]];
		}
	}
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	
	// If the releases controller was selected, remove the tab bar item badge
	if (self.tabBarController.selectedIndex == 1) {
		[self releasesTabBarItemBadgeValue:nil];
	}
	
	// When we're about to select a view controller, animate the indicator arrow on to that item
	[self animateArrowIndicatorToIndex:[self.tabBarController selectedIndex]];
	
	// Save which tab the user has selected
	[[NSUserDefaults standardUserDefaults] setInteger:self.tabBarController.selectedIndex forKey:@"TabBarSelectedIndex"];
}


- (void)showPlayer {
	self.tabBarController.selectedViewController = (UIViewController *)self.playerController;
	[self animateArrowIndicatorToIndex:[self.tabBarController selectedIndex]];
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
