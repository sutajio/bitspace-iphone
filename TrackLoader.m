//
//  TrackLoader.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-07.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "TrackLoader.h"


@implementation TrackLoader

@synthesize url, delegate;

- (BOOL)hasCacheForKey:(NSString*)key {
	return [[NSFileManager defaultManager] fileExistsAtPath:cachePathForKey(key)];
}

- (void)setCachedData:(NSData *)data forKey:(NSString *)key {
	[[NSFileManager defaultManager] createDirectoryAtPath:cachePathForKey(@"") 
							  withIntermediateDirectories:YES 
											   attributes:nil 
													error:NULL];
	[data writeToFile:cachePathForKey(key) atomically:YES];
}

- (void)main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"Downloading track: %@", url);
	[delegate loaderDidBegin];
	NSURL *dataUrl = [NSURL URLWithString:url];
	NSData *data = [NSData dataWithContentsOfURL:dataUrl];
	[self setCachedData:data forKey:url];	
	[delegate loaderDidFinish];
	NSLog(@"Download finished");
	[pool release];
}

@end
