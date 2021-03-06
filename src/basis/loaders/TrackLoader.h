//
//  TrackLoader.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-07.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TrackLoaderDelegate <NSObject>
@optional
- (void)loaderDidBegin;
- (void)loaderDidFinish;
- (void)loaderDidFailWithError:(NSError *)error;
@end

@interface TrackLoader : NSOperation {
	NSString *url;
	id <TrackLoaderDelegate> delegate;
	
	NSOutputStream *outputStream;
	BOOL done;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, assign) id <TrackLoaderDelegate> delegate;

+ (NSString *)cachePathForKey:(NSString *)key;

@end
