//
//  ArtworkLoader.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "ArtworkLoader.h"
#import "Release.h"


#define cachePathForKey(key) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"Cache/Artwork/%@", [key stringByReplacingOccurrencesOfString:@"/" withString:@"|"]]]


@implementation ArtworkLoader

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

- (NSData *)getCachedData:(NSString *)key {
	return [NSData dataWithContentsOfFile:cachePathForKey(key) options:0 error:NULL];
}

- (NSData *)cachedArtworkWithKey:(NSString *)key {
	if([self hasCacheForKey:key] == YES) {
		return [self getCachedData:key];
	} else {
		NSURL *dataUrl = [NSURL URLWithString:self.url];
		NSData *data = [NSData dataWithContentsOfURL:dataUrl];
		[self setCachedData:data forKey:key];
		return data;
	}
}

- (void)main {
	NSLog(@"ArtworkLoader#main");
	NSData *artworkData = [self cachedArtworkWithKey:self.url];
	UIImage *artworkImage = [UIImage imageWithData:artworkData];
	[delegate loaderDidFinishLoadingArtwork:artworkImage fromURL:self.url];
}

@end
