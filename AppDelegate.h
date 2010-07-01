//
//  bitspace_iphoneAppDelegate.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2009-11-30.
//  Copyright Koneko Collective Ltd. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayerController, ReleasesController;

@interface AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    NSString *siteURL;
	NSString *username;
	NSString *password;
	
	UIWindow *window;
    UITabBarController *tabBarController;
	PlayerController *playerController;
	ReleasesController *releasesController;
	
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, retain) NSString *siteURL;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet PlayerController *playerController;
@property (nonatomic, retain) IBOutlet ReleasesController *releasesController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

- (void)requestAuthenticationFromUser;
- (BOOL)validateUsername:(NSString *)username andPassword:(NSString *)password;
- (void)resetAppState;

@end
