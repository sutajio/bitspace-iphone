//
//  Release.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "Release.h"
#import "Track.h"


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
@dynamic tracks;

@synthesize smallArtworkLoader, mediumArtworkLoader, largeArtworkLoader;

-(NSString *)monthCreatedAt {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMM ''yy"];
	NSString *formatedDate = [dateFormatter stringFromDate:self.createdAt];
	[dateFormatter release];
	return formatedDate;
}

-(BOOL) hasTrackWithURL:(NSString *)url {
	for(Track *track in self.tracks) {
		if([track.url isEqualToString:url]) {
			return YES;
		}
	}
	return NO;
}

-(NSInteger) numberOfSets {
	NSInteger i = 1;
	for(Track *track in self.tracks) {
		if([track.setNr integerValue] > i) {
			i = [track.setNr integerValue];
		}
	}
	return i;
}

-(NSInteger) numberOfTracksInSet:(NSInteger)setNr {
	NSInteger i = 0;
	for(Track *track in self.tracks) {
		if([track.setNr integerValue] == setNr) {
			i++;
		}
	}
	return i;
}

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
				smallArtworkLoader = [[ArtworkLoader alloc] init];
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
				mediumArtworkLoader = [[ArtworkLoader alloc] init];
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
				largeArtworkLoader = [[ArtworkLoader alloc] init];
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

//-(void)dealloc {
//	[super dealloc];
//	[operationQueue release];
//	[smallArtworkLoader release];
//	[mediumArtworkLoader release];
//	[largeArtworkLoader release];
//	[smallArtworkImage release];
//	[mediumArtworkImage release];
//	[largeArtworkImage release];
//}

@end
