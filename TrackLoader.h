//
//  TrackLoader.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-07.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define cachePathForKey(key) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"Cache/Tracks/%@", [key stringByReplacingOccurrencesOfString:@"/" withString:@"|"]]]


@protocol TrackLoaderDelegate <NSObject>
@optional
- (void)loaderDidBegin;
- (void)loaderDidFinish;
@end

@interface TrackLoader : NSOperation {
	NSString *url;
	id <TrackLoaderDelegate> delegate;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, assign) id <TrackLoaderDelegate> delegate;

@end
