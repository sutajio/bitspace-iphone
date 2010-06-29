//
//  AppDelegate.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2009-11-30.
//  Copyright Koneko Collective Ltd. 2009. All rights reserved.
//

#import "AppDelegate.h"
#import "ObjectiveResource.h"
#import "PlayerController.h"
#import "ReleasesController.h"
#import "SignInController.h"
#import "Connection.h"
#import "Response.h"

@implementation AppDelegate

@synthesize siteURL, username, password;

@synthesize window;
@synthesize tabBarController;
@synthesize playerController;
@synthesize releasesController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	self.siteURL = @"http://bitspace.at/";
	self.username = [[NSUserDefaults standardUserDefaults] stringForKey:@"Username"];
	self.password = [[NSUserDefaults standardUserDefaults] stringForKey:@"Password"];
	
	// Pass self to the controllers
	playerController.appDelegate = self;
	releasesController.appDelegate = self;
	
	// Add a global background for the app
	UIView *backgroundView = [[UIView alloc] initWithFrame: window.frame];
	backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black-noise.jpg"]];
	[window addSubview:backgroundView];
	[backgroundView release];
	
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
	[window makeKeyAndVisible];
	
	// Show sign in screen
	if(!(self.username && self.password)) {
		[self requestAuthenticationFromUser];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
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


#pragma mark -
#pragma mark Authentication


- (void)requestAuthenticationFromUser {
	SignInController *signInController = [[SignInController alloc] init];
	signInController.appDelegate = self;
	tabBarController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[tabBarController presentModalViewController:signInController animated:YES];
	[signInController release];
}


- (BOOL)validateUsername:(NSString *)usernameValue andPassword:(NSString *)passwordValue {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@account", self.siteURL]];
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url
															cachePolicy:NSURLRequestReloadIgnoringCacheData
														timeoutInterval:[Connection timeout]];
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];	
	[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
	Response *res = [Connection sendRequest:request withUser:usernameValue andPassword:passwordValue];
	if([res isError]) {
		NSLog([res.error localizedDescription]);
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		return NO;
	}
	
	self.username = usernameValue;
	self.password = passwordValue;
	[[NSUserDefaults standardUserDefaults] setValue:usernameValue forKey:@"Username"];
	[[NSUserDefaults standardUserDefaults] setValue:passwordValue forKey:@"Password"];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	return YES;
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
		[managedObjectContext setRetainsRegisteredObjects:YES];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"bitspace.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[tabBarController release];
	[window release];
	[super dealloc];
}

@end

