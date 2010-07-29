//
//  Release.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "Release.h"
#import "Artist.h"
#import "Track.h"
#import "ObjectiveResourceDateFormatter.h"
#import "AppDelegate.h"


@implementation Release

@dynamic parent;
@dynamic title;
@dynamic artist;
@dynamic year;
@dynamic url;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic releaseDate;
@dynamic label;
@dynamic smallArtworkUrl;
@dynamic largeArtworkUrl;
@dynamic tracks;
@dynamic archived;

@synthesize smallArtworkImage, largeArtworkImage;
@synthesize smallArtworkLoader, largeArtworkLoader;

- (BOOL)hasTrack:(Track *)track {
	for(Track *t in self.tracks) {
		if(track == t) {
			return YES;
		}
	}
	return NO;
}

-(BOOL) hasTrackWithURL:(NSString *)url {
	for(Track *track in self.tracks) {
		if([track.url isEqualToString:url]) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)hasOnlineTracks {
	for(Track *track in self.tracks) {
		if([track hasCache] == NO) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)hasOfflineTracks {
	for(Track *track in self.tracks) {
		if([track hasCache] == YES) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)hasLoadingTracks {
	for(Track *track in self.tracks) {
		if([track isLoading] == YES) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)hasTracksQueuedForDownload {
	for(Track *track in self.tracks) {
		if(track.loader != nil) {
			return YES;
		}
	}
	return NO;
}

- (NSInteger)numberOfTracks {
	return [self.tracks count];
}

- (NSInteger)numberOfOfflineTracks {
	NSInteger i = 0;
	for(Track *track in self.tracks) {
		if([track hasCache]) {
			i++;
		}
	}
	return i;
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

+ (NSOperationQueue *)operationQueue {
	static NSOperationQueue *operationQueue;
    if (operationQueue == nil) {
        operationQueue = [[NSOperationQueue alloc] init];
		[operationQueue setMaxConcurrentOperationCount:1];
    }
    return operationQueue;
}

-(UIImage *)smallArtworkImage {
	if(smallArtworkImage == nil) {
		if(smallArtworkLoader == nil) {
			smallArtworkLoader = [[ArtworkLoader alloc] init];
			smallArtworkLoader.url = self.smallArtworkUrl;
			smallArtworkLoader.delegate = self;
			[[Release operationQueue] addOperation:smallArtworkLoader];
			[smallArtworkLoader release];
		}
	}
	return smallArtworkImage;
}

-(UIImage *)largeArtworkImage {
	if(largeArtworkImage == nil) {
		if(largeArtworkLoader == nil) {
			largeArtworkLoader = [[ArtworkLoader alloc] init];
			largeArtworkLoader.url = self.largeArtworkUrl;
			largeArtworkLoader.delegate = self;
			[[Release operationQueue] addOperation:largeArtworkLoader];
			[largeArtworkLoader release];
		}
	}
	return largeArtworkImage;
}

- (void)finishedLoadingSmallArtwork {
	if([NSThread isMainThread]) {
		smallArtworkLoader = nil;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLoadingSmallArtwork" object:self];
	} else {
		[self performSelectorOnMainThread:@selector(finishedLoadingSmallArtwork) withObject:nil waitUntilDone:NO];
	}
}

- (void)finishedLoadingLargeArtwork {
	if([NSThread isMainThread]) {
		largeArtworkLoader = nil;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLoadingLargeArtwork" object:self];
	} else {
		[self performSelectorOnMainThread:@selector(finishedLoadingLargeArtwork) withObject:nil waitUntilDone:NO];
	}
}

-(void)loaderDidFinishLoadingArtwork:(UIImage *)artworkImage fromURL:(NSString *)url {
	if([url isEqualToString:self.smallArtworkUrl]) {
		self.smallArtworkImage = artworkImage;
		[self finishedLoadingSmallArtwork];
	}
	if([url isEqualToString:self.largeArtworkUrl]) {
		self.largeArtworkImage = artworkImage;
		[self finishedLoadingLargeArtwork];
	}
}

- (void)didTurnIntoFault {
	[smallArtworkImage release]; smallArtworkImage = nil;
	[largeArtworkImage release]; largeArtworkImage = nil;
}

@end
