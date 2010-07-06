//
//  Release.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtworkLoader.h"
#import "ReleaseLoader.h"


@interface Release : NSManagedObject <ArtworkLoaderDelegate, ReleaseLoaderDelegate> {
	UIImage *smallArtworkImage;
	UIImage *largeArtworkImage;
	ArtworkLoader *smallArtworkLoader;
	ArtworkLoader *largeArtworkLoader;
	ReleaseLoader *releaseLoader;
	NSOperationQueue *operationQueue;
	BOOL touched;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *year;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *createdAt;
@property (nonatomic, retain) NSString *releaseDate;
@property (nonatomic, retain) NSString *label;
@property (nonatomic, retain) NSString *smallArtworkUrl;
@property (nonatomic, retain) NSString *largeArtworkUrl;
@property (nonatomic, retain) NSSet *tracks;

@property (nonatomic, retain) UIImage *smallArtworkImage;
@property (nonatomic, retain) UIImage *largeArtworkImage;
@property (nonatomic, retain) ArtworkLoader *smallArtworkLoader;
@property (nonatomic, retain) ArtworkLoader *largeArtworkLoader;
@property (nonatomic, retain) ReleaseLoader *releaseLoader;
@property (nonatomic, retain) NSOperationQueue *operationQueue;

- (BOOL)hasTrackWithURL:(NSString *)url;
- (NSInteger)numberOfSets;
- (NSInteger)numberOfTracksInSet:(NSInteger)setNr;
- (void)loadTracks:(BOOL)force;
- (void)touch;
- (BOOL)wasTouched;

@end
