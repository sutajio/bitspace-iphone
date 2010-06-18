//
//  ReleasesLoader.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate, ReleasesLoader;

@protocol ReleasesLoaderDelegate <NSObject>
@optional
- (void)loaderDidSave:(NSNotification *)saveNotification;
- (void)loaderDidFinish:(ReleasesLoader *)loader;
- (void)loaderDidFinishLoadingPage:(ReleasesLoader *)loader;
- (void)loader:(ReleasesLoader *)loader didFailWithError:(NSError *)error;
@end

@interface ReleasesLoader : NSOperation {
	id <ReleasesLoaderDelegate> delegate;
	AppDelegate *appDelegate;
}

@property (nonatomic, assign) id <ReleasesLoaderDelegate> delegate;
@property (nonatomic, retain) AppDelegate *appDelegate;

@end
