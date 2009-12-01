//
//  bitspace_iphoneAppDelegate.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2009-11-30.
//  Copyright Koneko Collective Ltd. 2009. All rights reserved.
//

#import "bitspace_iphoneAppDelegate.h"
#import "ObjectiveResource.h"

@implementation bitspace_iphoneAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	// Configure ObjectiveResource
	[ObjectiveResourceConfig setSite:@"http://localhost:3000/api/"];
	[ObjectiveResourceConfig setUser:@"admin"];
	[ObjectiveResourceConfig setPassword:@"koneko"];
	[ObjectiveResourceConfig setResponseType:JSONResponse];
	
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
}


/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

