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
	NSOperationQueue *operationQueue;
	UIImage *smallArtworkImage;
	UIImage *mediumArtworkImage;
	UIImage *largeArtworkImage;
	ArtworkLoader *smallArtworkLoader;
	ArtworkLoader *mediumArtworkLoader;
	ArtworkLoader *largeArtworkLoader;
	ReleaseLoader *releaseLoader;
	BOOL touched;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *year;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, readonly) NSString *monthCreatedAt;
@property (nonatomic, retain) NSString *releaseDate;
@property (nonatomic, retain) NSString *label;
@property (nonatomic, retain) NSString *smallArtworkUrl;
@property (nonatomic, retain) NSString *mediumArtworkUrl;
@property (nonatomic, retain) NSString *largeArtworkUrl;
@property (nonatomic, retain) NSData *smallArtwork;
@property (nonatomic, retain) NSData *mediumArtwork;
@property (nonatomic, retain) NSData *largeArtwork;
@property (nonatomic, retain) NSSet *tracks;

@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, retain, readonly) UIImage *smallArtworkImage;
@property (nonatomic, retain, readonly) UIImage *mediumArtworkImage;
@property (nonatomic, retain, readonly) UIImage *largeArtworkImage;
@property (nonatomic, retain) ArtworkLoader *smallArtworkLoader;
@property (nonatomic, retain) ArtworkLoader *mediumArtworkLoader;
@property (nonatomic, retain) ArtworkLoader *largeArtworkLoader;
@property (nonatomic, retain) ReleaseLoader *releaseLoader;

- (BOOL)hasTrackWithURL:(NSString *)url;
- (NSInteger)numberOfSets;
- (NSInteger)numberOfTracksInSet:(NSInteger)setNr;
- (void)loadTracksWithAppDelegate:(AppDelegate *)appDelegate;
- (void)touch;
- (BOOL)wasTouched;

@end
