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

+ (NSOutputStream *)outputStreamForKey:(NSString *)key {
	[[NSFileManager defaultManager] createDirectoryAtPath:cachePathForKey(@"") 
							  withIntermediateDirectories:YES 
											   attributes:nil 
													error:NULL];
	return [NSOutputStream outputStreamToFileAtPath:cachePathForKey(key) append:NO];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[outputStream open];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	done = YES;
	[delegate loaderDidFailWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if(outputStream) {
		[outputStream write:[data bytes] maxLength:[data length]];
	} else {
		NSLog(@"Fail");
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	done = YES;
	[outputStream close];
}

- (void)main {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"Downloading track: %@", url);
	[delegate loaderDidBegin];
	
	done = NO;
	NSURL *dataUrl = [NSURL URLWithString:url];
	NSURLRequest *request = [NSURLRequest requestWithURL:dataUrl];
	NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO] autorelease];
	if(connection) {
		outputStream = [TrackLoader outputStreamForKey:url];
		static NSString *runLoopMode = @"com.sutajio.bitspace.TrackLoader";
		[connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:runLoopMode];
		[connection start];
		while (done == NO) {
			[[NSRunLoop currentRunLoop] runMode:runLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.3]];
		}
	}
	
	[delegate loaderDidFinish];
	NSLog(@"Download finished");
	[pool release];
}

@end
