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
@dynamic loader;

- (BOOL)hasCache {
	return [[NSFileManager defaultManager] fileExistsAtPath:cachePathForKey(self.url)];
}

- (BOOL)isLoading {
	return [self.loading boolValue];
}

- (NSString *)cachedFilePath {
	return cachePathForKey(self.url);
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
		[[NSFileManager defaultManager] removeItemAtPath:cachePathForKey(self.url) error:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackOfflineModeDidClear" object:self];
	}
}

- (void)toggleLove {
	NSLog(@"Love");
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSURL *url = [ProtectedURL URLWithStringAndCredentials:self.loveUrl withUser:appDelegate.username andPassword:appDelegate.password];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestReloadIgnoringCacheData
													   timeoutInterval:5.0];
	[request setHTTPMethod:@"PUT"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request addValue:[ProtectedURL authorizationHeaderWithUser:appDelegate.username 
													andPassword:appDelegate.password] forHTTPHeaderField:@"Authorization"];
	if(self.lovedAt) {
		[request setHTTPBody:[@"toggle=off" dataUsingEncoding:NSUTF8StringEncoding]];
		self.lovedAt = nil;
	} else {
		[request setHTTPBody:[@"toggle=on" dataUsingEncoding:NSUTF8StringEncoding]];
		self.lovedAt = [NSDate date];
	}
	[self.managedObjectContext save:nil];
	[appDelegate.syncQueue enqueueRequest:request];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TrackLoveStateDidChange" object:self];
}

- (void)touch {
	self.touched = [NSNumber numberWithBool:YES];
}

- (BOOL)wasTouched {
	return [self.touched boolValue];
}

@end
