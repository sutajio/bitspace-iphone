//
//  Release.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtworkLoader.h"

@class Artist, Track;

@interface Release : NSManagedObject <ArtworkLoaderDelegate> {
	UIImage *smallArtworkImage;
	UIImage *largeArtworkImage;
	ArtworkLoader *smallArtworkLoader;
	ArtworkLoader *largeArtworkLoader;
	NSOperationQueue *operationQueue;
	BOOL touched;
}

@property (nonatomic, retain) Artist *parent;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *year;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *createdAt;
@property (nonatomic, retain) NSString *updatedAt;
@property (nonatomic, retain) NSString *releaseDate;
@property (nonatomic, retain) NSString *label;
@property (nonatomic, retain) NSString *smallArtworkUrl;
@property (nonatomic, retain) NSString *largeArtworkUrl;
@property (nonatomic, retain) NSSet *tracks;

@property (nonatomic, retain) UIImage *smallArtworkImage;
@property (nonatomic, retain) UIImage *largeArtworkImage;
@property (nonatomic, retain) ArtworkLoader *smallArtworkLoader;
@property (nonatomic, retain) ArtworkLoader *largeArtworkLoader;
@property (nonatomic, retain) NSOperationQueue *operationQueue;

- (BOOL)hasTrack:(Track *)track;
- (BOOL)hasTrackWithURL:(NSString *)url;
- (BOOL)hasOnlineTracks;
- (BOOL)hasOfflineTracks;
- (BOOL)hasLoadingTracks;
- (BOOL)hasTracksQueuedForDownload;
- (NSInteger)numberOfTracks;
- (NSInteger)numberOfOfflineTracks;
- (NSInteger)numberOfSets;
- (NSInteger)numberOfTracksInSet:(NSInteger)setNr;
- (void)touch;
- (BOOL)wasTouched;

@end
