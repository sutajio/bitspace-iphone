//
//  SyncQueue.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-02.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "SyncQueue.h"


@implementation SyncQueue

- (SyncQueue *)init {
	if(self = [super init]) {
		syncTimer =
		[NSTimer
		 scheduledTimerWithTimeInterval:10.0f
		 target:self
		 selector:@selector(forceSync)
		 userInfo:nil
		 repeats:YES];
	}
	return self;
}

- (NSMutableArray *)queuedRequests {
	if(queuedRequests == nil) {
		queuedRequests = [[NSMutableArray alloc] init];
	}
	return queuedRequests;
}

- (void)sendRequest:(NSURLRequest *)request {
	NSAutoreleasePool *innerPool = [[NSAutoreleasePool alloc] init];
	NSLog(@"%@ -> %@", [request HTTPMethod], [request URL]);
	NSError *error;
	if ([NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error]) {
		[self performSelectorOnMainThread:@selector(dequeueRequest:) withObject:request waitUntilDone:NO];
	} else {
		NSLog(@"%@", [error localizedDescription]);
	}
	[innerPool release];
}

- (void)enqueueRequest:(NSURLRequest *)request {
	NSMutableArray *queue = [self queuedRequests];
	[queue addObject:request];
}

- (void)dequeueRequest:(NSURLRequest *)request {
	NSMutableArray *queue = [self queuedRequests];
	[queue removeObject:request];
}

- (void)forceSync {
	NSMutableArray *queue = [self queuedRequests];
	for(NSURLRequest *request in queue) {
		[self performSelectorInBackground:@selector(sendRequest:) withObject:request];
	}
}

- (void)dealloc {
	[syncTimer release];
	[queuedRequests release];
	[super dealloc];
}

@end
