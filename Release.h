//
//  Release.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtworkLoader.h"


@interface Release : NSManagedObject <ArtworkLoaderDelegate> {
	NSOperationQueue *operationQueue;
	UIImage *smallArtworkImage;
	UIImage *mediumArtworkImage;
	UIImage *largeArtworkImage;
	ArtworkLoader *smallArtworkLoader;
	ArtworkLoader *mediumArtworkLoader;
	ArtworkLoader *largeArtworkLoader;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *year;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSDate *createdAt;
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

-(BOOL) hasTrackWithURL:(NSString *)url;

@end
