//
//  Track.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-17.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "Track.h"
#import "AppDelegate.h"


@implementation Track

@dynamic parent;
@dynamic title;
@dynamic url;
@dynamic artist;
@dynamic trackNr;
@dynamic setNr;
@dynamic length;
@dynamic nowPlayingUrl;
@dynamic scrobbleUrl;
@dynamic loveUrl;
@dynamic lovedAt;
@dynamic touched;
@dynamic loading;
@dynamic loader;

- (BOOL)hasCache {
	return [[NSFileManager defaultManager] fileExistsAtPath:cachePathForKey(self.url)];
}

- (BOOL)isLoading {
	return [self.loading boolValue];
}

- (NSData *)cachedData {
	return [NSData dataWithContentsOfFile:cachePathForKey(self.url) options:0 error:NULL];
}

- (void)loaderDidBegin {
	if([NSThread isMainThread] == YES) {
		self.loading = [NSNumber numberWithBool:YES];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackOfflineModeDownloadDidBegin" object:self];
	} else {
		[self performSelectorOnMainThread:@selector(loaderDidBegin) withObject:nil waitUntilDone:NO];
	}
}

- (void)loaderDidFinish {
	if([NSThread isMainThread] == YES) {
		self.loading = [NSNumber numberWithBool:NO];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackOfflineModeDownloadDidFinish" object:self];
	} else {
		[self performSelectorOnMainThread:@selector(loaderDidFinish) withObject:nil waitUntilDone:NO];
	}
}

- (void)enableOfflineMode {
	if([self hasCache] == NO) {
		if(self.isLoading == NO) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackOfflineModeDownloadWillBegin" object:self];
			self.loader = [[TrackLoader alloc] init];
			self.loader.url = self.url;
			self.loader.delegate = self;
			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			[appDelegate.operationQueue addOperation:self.loader];
			[self.loader release];
		}
	}
}

- (void)clearCache {
	if([self hasCache] && self.isLoading == NO) {
		NSLog(@"Zapp!! %@", self.url);
		[[NSFileManager defaultManager] removeItemAtPath:cachePathForKey(self.url) error:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackOfflineModeDidClear" object:self];
	}
}

@end
