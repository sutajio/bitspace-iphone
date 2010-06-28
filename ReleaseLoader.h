//
//  ReleaseLoader.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-17.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate, Release, ReleaseLoader;

@protocol ReleaseLoaderDelegate <NSObject>
@optional
- (void)loaderDidFinish:(ReleaseLoader *)loader;
- (void)loaderDidFinishParsingRelease:(NSDictionary *)releaseJSON;
- (void)loader:(ReleaseLoader *)loader didFailWithError:(NSError *)error;
@end

@interface ReleaseLoader : NSOperation {
	AppDelegate *appDelegate;
	NSString *releaseURL;
	id <ReleaseLoaderDelegate> delegate;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) NSString *releaseURL;
@property (nonatomic, assign) id <ReleaseLoaderDelegate> delegate;

@end
