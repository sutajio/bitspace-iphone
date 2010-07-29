//
//  AppDelegate_iPhone.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-25.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@class ArtistsController, ReleasesController, FavoritesController;

@interface AppDelegate_iPhone : AppDelegate {
    UITabBarController *tabBarController;
	ArtistsController *artistsController;
	ReleasesController *releasesController;
	FavoritesController *favoritesController;
}

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet ArtistsController *artistsController;
@property (nonatomic, retain) IBOutlet ReleasesController *releasesController;
@property (nonatomic, retain) IBOutlet FavoritesController *favoritesController;

@end
