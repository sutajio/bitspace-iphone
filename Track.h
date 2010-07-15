//
//  Track.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-17.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrackLoader.h"

@class Release;

@interface Track : NSManagedObject <TrackLoaderDelegate> {

}

@property (nonatomic, retain) Release *parent;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSNumber *trackNr;
@property (nonatomic, retain) NSNumber *setNr;
@property (nonatomic, retain) NSNumber *length;
@property (nonatomic, retain) NSString *nowPlayingUrl;
@property (nonatomic, retain) NSString *scrobbleUrl;
@property (nonatomic, retain) NSString *loveUrl;
@property (nonatomic, retain) NSDate *lovedAt;
@property (nonatomic, retain) NSNumber *touched;
@property (nonatomic, retain) NSNumber *loading;
@property (nonatomic, retain) TrackLoader *loader;

- (BOOL)hasCache;
- (BOOL)isLoading;
- (NSString *)cachedFilePath;
- (void)enableOfflineMode;
- (void)clearCache;
- (void)toggleLove;
- (void)touch;
- (BOOL)wasTouched;

@end
