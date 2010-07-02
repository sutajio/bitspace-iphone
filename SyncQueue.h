//
//  SyncQueue.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-02.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SyncQueue : NSObject {
	NSMutableArray *queuedRequests;
}

- (void)enqueueRequest:(NSURLRequest *)request;
- (void)dequeueRequest:(NSURLRequest *)request;
- (void)forceSync;

@end
