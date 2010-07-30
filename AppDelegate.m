//
//  AppDelegate.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2009-11-30.
//  Copyright Koneko Collective Ltd. 2009. All rights reserved.
//

#import "AppDelegate.h"
#import "ObjectiveResource.h"
#import "Connection.h"
#import "Response.h"
#import "SyncQueue.h"
#import "PlayerController.h"
#import "LoadingController.h"


@interface AppDelegate ()
- (BOOL)validateUsername:(NSString *)username andPassword:(NSString *)password;
- (void)requestAuthenticationFromUser;
@end


@implementation AppDelegate

@synthesize window;
@synthesize playerController;
@synthesize siteURL, username, password;
@synthesize operationQueue;
@synthesize releasesLoader, lastSynchronizationDate;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Never accept cookies
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyNever];
	
	// Set the site URL, which is the Bitspace API end-point where all data is loaded from
	self.siteURL = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SiteURL"];
	
	// Authenticate user and show sign in screen if authentication fails
	if([self validateUsername:[[NSUserDefaults standardUserDefaults] stringForKey:@"Username"]
				  andPassword:[[NSUserDefaults standardUserDefaults] stringForKey:@"Password"]] == NO) {
		[self requestAuthenticationFromUser];
	}
	
	// Begin receiving remote control events
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
	if ([[UIApplication sharedApplication]
		 respondsToSelector:@selector(beginReceivingRemoteControlEvents)])
    {
		[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	}
#endif
	
	// Pass self to the player controller
	self.playerController.appDelegate = self;
	
	// Watch for release-synchronization events
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(synchronize) 
												 name:@"Synchronize" 
											   object:nil];
	
	// Watch for release-synchronization events
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(forceSynchronization) 
												 name:@"ForceSynchronization" 
											   object:nil];
	
	// Watch for shake events
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(requestAuthenticationFromUser) 
												 name:@"DeviceShaken" 
											   object:nil];
	
	// Watch for authenticate events
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(requestAuthenticationFromUser) 
												 name:@"Authenticate" 
											   object:nil];
	
	// Watch for sign in events
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(userDidSignIn) 
												 name:@"UserDidSignIn" 
											   object:nil];
	
	// Watch for network error events
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleNetworkError:) 
												 name:@"NetworkError" 
											   object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	
	// Save application state
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// Save the database if it has changes
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[self applicationDidReceiveMemoryWarning:application];
}


#pragma mark -
#pragma mark Player

- (void)showPlayer {
	// This method is overriden in the device specific AppDelegate classes
}


#pragma mark -
#pragma mark Modal loading indicator

- (void)presentModalLoadingIndicator {
	if(modalLoadingIndicator == nil) {
		modalLoadingIndicator = [[LoadingController alloc] initWithNibName:@"Loading" bundle:nil];
		modalLoadingIndicator.view.alpha = 0.0f;
		[window addSubview:modalLoadingIndicator.view];
	}
	[UIView beginAnimations:@"ModalLoadingIndicator" context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationBeginsFromCurrentState:YES];
	modalLoadingIndicator.view.alpha = 1.0f;
	[UIView commitAnimations];
}


- (void)dismissModalLoadingIndicator {
	if(modalLoadingIndicator) {
		[UIView beginAnimations:@"ModalLoadingIndicator" context:nil];
		[UIView setAnimationDuration:0.5f];
		[UIView setAnimationBeginsFromCurrentState:YES];
		modalLoadingIndicator.view.alpha = 0.0f;
		[UIView commitAnimations];
	}
}


#pragma mark -
#pragma mark Error handling

- (void)handleNetworkError:(NSNotification *)notification {
	NSError *error = (NSError *)[notification object];
	UIAlertView *alertView = nil;
	switch ([error code]) {
		case 401:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"Authenticate" object:nil];
			break;
		case NSURLErrorUserAuthenticationRequired:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"Authenticate" object:nil];
			break;
		case NSURLErrorNotConnectedToInternet:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"EnableOfflineMode" object:nil];
			break;
		default:
			alertView = [[UIAlertView alloc] initWithTitle:@"Network error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			break;
	}
}

#pragma mark -
#pragma mark SyncQueue

- (SyncQueue *)syncQueue {
	if(syncQueue == nil) {
		syncQueue = [[SyncQueue alloc] init];
	}
	return syncQueue;
}


#pragma mark -
#pragma mark Authentication

- (void)requestAuthenticationFromUser {
	// This method is overriden in the device specific AppDelegate classes
}


- (BOOL)validateUsername:(NSString *)usernameValue andPassword:(NSString *)passwordValue {
	
	if(usernameValue == nil || passwordValue == nil)
		return NO;
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@account", self.siteURL]];
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url
															cachePolicy:NSURLRequestReloadIgnoringCacheData
														timeoutInterval:[Connection timeout]];
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];	
	[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	Response *res = [Connection sendRequest:request withUser:usernameValue andPassword:passwordValue];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if([res isError]) {
		NSLog(@"Network error: %@", [res.error localizedDescription]);
		if([res.error code] != 401) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkError" object:res.error];
			self.username = usernameValue;
			self.password = passwordValue;
			return YES;
		}
		return NO;
	}
	
	self.username = usernameValue;
	self.password = passwordValue;
	
	return YES;
}


- (void)resetUI {
	// This method is overriden in the device specific AppDelegate classes
}


- (void)resetAppState {
	NSLog(@"AppDelegate#resetAppState");
	
	// Show the player
	[self showPlayer];
	
	// Stop audio playback
	[self.playerController stopPlayback];
	[self.playerController clearQueueAndResetPlayer:YES];
	
	// Reset the user interface
	[self resetUI];
	
	// Stop operation queue
	[self.operationQueue cancelAllOperations];
	
	// Reset CoreData
	[managedObjectContext release]; managedObjectContext = nil;
	[managedObjectModel release]; managedObjectModel = nil;
	[persistentStoreCoordinator release]; persistentStoreCoordinator = nil;
	
	// Reset the last synchronization date, to force a synchronization
	[[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"LastReleasesSync"];
	
	// Send out a ResetAppState message to all controllers
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ResetAppState" object:nil];
}


- (void)userDidSignIn {
	
	// Save old username
	NSString *oldUsername = [[NSUserDefaults standardUserDefaults] stringForKey:@"Username"];
	
	// If a new user signed in; reset app state
	if(oldUsername && [oldUsername isEqualToString:self.username] == NO) {
		[self resetAppState];
	}
	
	// Save the username and password, so that the user doesn't need to sign in the next
	// time he or she starts the app.
	[[NSUserDefaults standardUserDefaults] setValue:self.username forKey:@"Username"];
	[[NSUserDefaults standardUserDefaults] setValue:self.password forKey:@"Password"];
	
	// Synchronize, if needed...
	[[NSNotificationCenter defaultCenter] postNotificationName:@"Synchronize" object:nil];	
}


#pragma mark -
#pragma mark Operation queue


- (NSOperationQueue *)operationQueue {
    if (operationQueue == nil) {
        operationQueue = [[NSOperationQueue alloc] init];
		[operationQueue setMaxConcurrentOperationCount:3];
    }
    return operationQueue;
}


#pragma mark -
#pragma mark Synchronization

- (NSDate *)lastSynchronizationDate {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"LastReleasesSync"];
}


- (BOOL)shouldSynchronize {
	NSTimeInterval synchronizationInterval = (NSTimeInterval)[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"SynchronizationInterval"] doubleValue];
	NSDate *lastSync = [self lastSynchronizationDate] ? [self lastSynchronizationDate] : [NSDate distantPast];
	return [lastSync timeIntervalSinceNow] <= -synchronizationInterval ? YES : NO;
}


- (void)forceSynchronization {
	if (releasesLoader == nil) {
		releasesLoader = [[ReleasesLoader alloc] init];
		releasesLoader.delegate = self;
		releasesLoader.persistentStoreCoordinator = self.persistentStoreCoordinator;
		releasesLoader.lastUpdateDate = [self lastSynchronizationDate];
		[self.operationQueue addOperation:releasesLoader];
	}
}


- (void)synchronize {	
	if([self shouldSynchronize] == YES) {
		[self forceSynchronization];
	}
}


#pragma mark -
#pragma mark <ReleasesLoaderDelegate> Implementation


- (void)loaderDidSave:(NSNotification *)saveNotification {
    if([NSThread isMainThread]) {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ReleasesSynchronizationDidSave" object:self];
    } else {
        [self performSelectorOnMainThread:@selector(loaderDidSave:) withObject:saveNotification waitUntilDone:NO];
    }
}


- (void)loaderDidFinish:(ReleasesLoader *)loader {
	if([NSThread isMainThread]) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[self dismissModalLoadingIndicator];
		if(loader.didFail == NO) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastReleasesSync"];
		}
		[releasesLoader release];
		releasesLoader = nil;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ReleasesSynchronizationDidFinish" object:self];
	} else {
		[self performSelectorOnMainThread:@selector(loaderDidFinish:) withObject:loader waitUntilDone:NO];
	}
}


- (void)loaderDidFinishLoadingPage:(ReleasesLoader *)loader {
	if([NSThread isMainThread]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ReleasesSynchronizationDidFinishLoadingPage" object:self];
	} else {
		[self performSelectorOnMainThread:@selector(loaderDidFinishLoadingPage:) withObject:loader waitUntilDone:NO];
	}
}


- (void)loaderDidFinishParsingRelease:(ReleasesLoader *)loader {
	if([NSThread isMainThread]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ReleasesSynchronizationDidFinishParsingRelease" object:self];
	} else {
		[self performSelectorOnMainThread:@selector(loaderDidFinishParsingRelease:) withObject:loader waitUntilDone:NO];
	}
}


- (void)loaderDidStart:(ReleasesLoader *)loader {
	if([NSThread isMainThread]) {
		if([self lastSynchronizationDate]) {
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		} else {
			[self presentModalLoadingIndicator];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ReleasesSynchronizationDidStart" object:self];
	} else {
		[self performSelectorOnMainThread:@selector(loaderDidStart:) withObject:loader waitUntilDone:NO];
	}
}

- (void)dispatchNetworkError:(NSError *)error {
	if([NSThread isMainThread]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkError" object:error];
	} else {
		[self performSelectorOnMainThread:@selector(dispatchNetworkError:) withObject:error waitUntilDone:NO];
	}
}

- (void)loader:(ReleasesLoader *)loader didFailWithError:(NSError *)error {
	[self dispatchNetworkError:error];
}


#pragma mark -
#pragma mark Core Data stack

- (NSString *)databaseFilename {
	return [NSString stringWithFormat:@"bitspace-%@.sqlite", self.username];
}


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
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: [self databaseFilename]]];
	
	NSLog(@"Opening peristent store with URL \"%@\"", storeUrl);
	
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

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	for(NSManagedObject *obj in [self.managedObjectContext registeredObjects]) {
		if([obj respondsToSelector:@selector(didReceiveMemoryWarning)])
			[obj performSelector:@selector(didReceiveMemoryWarning)];
	}
}


- (void)dealloc {
	[syncQueue release];
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[window release];
	[super dealloc];
}

@end

