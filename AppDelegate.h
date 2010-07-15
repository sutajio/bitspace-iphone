//
//  bitspace_iphoneAppDelegate.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2009-11-30.
//  Copyright Koneko Collective Ltd. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReleasesLoader.h"

@class PlayerController, ArtistsController, ReleasesController, FavoritesController, SyncQueue;

@interface AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, ReleasesLoaderDelegate> {
    NSString *siteURL;
	NSString *username;
	NSString *password;
	
	NSOperationQueue *operationQueue;
	
	UIWindow *window;
    UITabBarController *tabBarController;
	PlayerController *playerController;
	ArtistsController *artistsController;
	ReleasesController *releasesController;
	FavoritesController *favoritesController;
	
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
	SyncQueue *syncQueue;
	
	ReleasesLoader *releasesLoader;
}

@property (nonatomic, retain) NSString *siteURL;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet PlayerController *playerController;
@property (nonatomic, retain) IBOutlet ArtistsController *artistsController;
@property (nonatomic, retain) IBOutlet ReleasesController *releasesController;
@property (nonatomic, retain) IBOutlet FavoritesController *favoritesController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain, readonly) SyncQueue *syncQueue;

@property (nonatomic, retain, readonly) ReleasesLoader *releasesLoader;
@property (nonatomic, readonly) NSDate *lastSynchronizationDate;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

- (void)requestAuthenticationFromUser;
- (BOOL)validateUsername:(NSString *)username andPassword:(NSString *)password;
- (void)resetAppState;

@end
