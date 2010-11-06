//
//  AppDelegate_iPhone.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-25.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@class ReleasesController, NewsController;

@interface AppDelegate_iPhone : AppDelegate {
	UITabBarController *tabBarController;
	UIImageView *indicatorImage;
	ReleasesController *releasesController;
	NewsController *favoritesController;
}

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet ReleasesController *releasesController;
@property (nonatomic, retain) IBOutlet NewsController *favoritesController;

@end
