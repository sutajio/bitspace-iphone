//
//  ReleasesLoader.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ReleasesLoader;

@protocol ReleasesLoaderDelegate <NSObject>
@optional
- (void)loaderDidFinish:(ReleasesLoader *)loader;
- (void)loaderDidFinishLoadingPage:(ReleasesLoader *)loader;
- (void)loaderDidFinishParsingRelease:(ReleasesLoader *)loader;
- (void)loaderDidStart:(ReleasesLoader *)loader;
- (void)loader:(ReleasesLoader *)loader didFailWithError:(NSError *)error;
@end

@interface ReleasesLoader : NSOperation {
	id <ReleasesLoaderDelegate> delegate;
	NSManagedObjectContext *insertionContext;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSEntityDescription *artistEntityDescription;
	NSEntityDescription *releaseEntityDescription;
	NSEntityDescription *trackEntityDescription;
	NSArray *cachedReleases;
	NSArray *cachedTracks;
}

@property (nonatomic, assign) id <ReleasesLoaderDelegate> delegate;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectContext *insertionContext;
@property (nonatomic, retain, readonly) NSEntityDescription *artistEntityDescription;
@property (nonatomic, retain, readonly) NSEntityDescription *releaseEntityDescription;
@property (nonatomic, retain, readonly) NSEntityDescription *trackEntityDescription;

@end
