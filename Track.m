//
//  Track.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-17.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "Track.h"
#import "AppDelegate.h"
#import "SyncQueue.h"
#import "ProtectedURL.h"


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
@dynamic cached;
@dynamic loader;

- (BOOL)hasCache {
	return [self.cached boolValue];
}

- (BOOL)isLoading {
	return [self.loading boolValue];
}

- (NSString *)cachedFilePath {
	return [TrackLoader cachePathForKey:self.url];
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
		self.loader = nil;
		self.cached = [NSNumber numberWithBool:[[NSFileManager defaultManager] fileExistsAtPath:[TrackLoader cachePathForKey:self.url]]];
		NSError *error = nil;
		if(![self.managedObjectContext save:&error]) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"DatabaseError" object:error];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackOfflineModeDownloadDidFinish" object:self];
	} else {
		[self performSelectorOnMainThread:@selector(loaderDidFinish) withObject:nil waitUntilDone:NO];
	}
}

- (void)loaderDidFailWithError:(NSError *)error {
	if([NSThread isMainThread] == YES) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkError" object:error];
	} else {
		[self performSelectorOnMainThread:@selector(loaderDidFailWithError:) withObject:error waitUntilDone:NO];
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
		self.cached = [NSNumber numberWithBool:NO];
		NSError *error = nil;
		if(![self.managedObjectContext save:&error]) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"DatabaseError" object:error];
		}
		[[NSFileManager defaultManager] removeItemAtPath:[TrackLoader cachePathForKey:self.url] error:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackOfflineModeDidClear" object:self];
	}
}

- (void)touch {
	self.touched = [NSNumber numberWithBool:YES];
}

- (BOOL)wasTouched {
	return [self.touched boolValue];
}

@end
