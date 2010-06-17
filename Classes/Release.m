//
//  Release.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "Release.h"
#import "ArtworkLoader.h"


@implementation Release

@dynamic title;
@dynamic artist;
@dynamic year;
@dynamic url;
@dynamic createdAt;
@dynamic smallArtworkUrl;
@dynamic mediumArtworkUrl;
@dynamic largeArtworkUrl;
@dynamic smallArtwork;
@dynamic mediumArtwork;
@dynamic largeArtwork;

@synthesize smallArtworkLoader, mediumArtworkLoader, largeArtworkLoader;

- (NSOperationQueue *)operationQueue {
    if (operationQueue == nil) {
        operationQueue = [[NSOperationQueue alloc] init];
    }
    return operationQueue;
}

-(UIImage *)smallArtworkImage {
	if(smallArtworkImage == nil) {
		if(self.smallArtwork == nil) {
			if(smallArtworkLoader == nil) {
				smallArtworkLoader = [[[ArtworkLoader alloc] init] autorelease];
				smallArtworkLoader.url = self.smallArtworkUrl;
				smallArtworkLoader.delegate = self;
				[self.operationQueue addOperation:smallArtworkLoader];
			}
		} else {
			smallArtworkImage = [[UIImage imageWithData:self.smallArtwork] retain];
		}
	}
	return smallArtworkImage;
}

-(UIImage *)mediumArtworkImage {
	if(mediumArtworkImage == nil) {
		if(self.mediumArtwork == nil) {
			if(mediumArtworkLoader == nil) {
				mediumArtworkLoader = [[[ArtworkLoader alloc] init] autorelease];
				mediumArtworkLoader.url = self.mediumArtworkUrl;
				mediumArtworkLoader.delegate = self;
				[self.operationQueue addOperation:mediumArtworkLoader];
			}
		} else {
			mediumArtworkImage = [[UIImage imageWithData:self.mediumArtwork] retain];
		}
	}
	return mediumArtworkImage;
}

-(UIImage *)largeArtworkImage {
	if(largeArtworkImage == nil) {
		if(self.largeArtwork == nil) {
			if(largeArtworkLoader == nil) {
				largeArtworkLoader = [[[ArtworkLoader alloc] init] autorelease];
				largeArtworkLoader.url = self.largeArtworkUrl;
				largeArtworkLoader.delegate = self;
				[self.operationQueue addOperation:largeArtworkLoader];
			}
		} else {
			largeArtworkImage = [[UIImage imageWithData:self.largeArtwork] retain];
		}
	}
	return largeArtworkImage;
}

-(void)loaderDidFinishLoadingArtwork:(NSData *)artworkData fromURL:(NSString *)url {
	if([url isEqualToString:self.smallArtworkUrl]) {
		self.smallArtwork = artworkData;
	}
	if([url isEqualToString:self.mediumArtworkUrl]) {
		self.mediumArtwork = artworkData;
	}
	if([url isEqualToString:self.largeArtworkUrl]) {
		self.largeArtwork = artworkData;
	}
}

-(void)dealloc {
	[super dealloc];
	[operationQueue release];
	[smallArtworkLoader release];
	[mediumArtworkLoader release];
	[largeArtworkLoader release];
	[smallArtworkImage release];
	[mediumArtworkImage release];
	[largeArtworkImage release];
}

@end
