//
//  Artist.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-13.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "Artist.h"
#import "AppDelegate.h"
#import "ProtectedURL.h"


@implementation Artist

@dynamic name;
@dynamic sortName;
@dynamic sectionName;
@dynamic artistType;
@dynamic beginDate;
@dynamic endDate;
@dynamic website;
@dynamic smallArtworkUrl;
@dynamic largeArtworkUrl;
@dynamic biographyUrl;
@dynamic archived;
@dynamic releases;

@synthesize smallArtworkImage, largeArtworkImage;
@synthesize smallArtworkLoader, largeArtworkLoader;

+ (NSOperationQueue *)operationQueue {
	static NSOperationQueue *operationQueue;
    if (operationQueue == nil) {
        operationQueue = [[NSOperationQueue alloc] init];
		[operationQueue setMaxConcurrentOperationCount:1];
    }
    return operationQueue;
}

- (UIImage *)smallArtworkImage {
	if(smallArtworkImage == nil && self.smallArtworkUrl != nil) {
		if(smallArtworkLoader == nil) {
			smallArtworkLoader = [[ArtworkLoader alloc] init];
			smallArtworkLoader.url = self.smallArtworkUrl;
			smallArtworkLoader.delegate = self;
			[[Artist operationQueue] addOperation:smallArtworkLoader];
			[smallArtworkLoader release];
		}
	}
	return smallArtworkImage;
}

- (UIImage *)largeArtworkImage {
	if(largeArtworkImage == nil && self.largeArtworkUrl != nil) {
		if(largeArtworkLoader == nil) {
			largeArtworkLoader = [[ArtworkLoader alloc] init];
			largeArtworkLoader.url = self.largeArtworkUrl;
			largeArtworkLoader.delegate = self;
			[[Artist operationQueue] addOperation:largeArtworkLoader];
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

- (void)loaderDidFinishLoadingArtwork:(UIImage *)artworkImage fromURL:(NSString *)url {
	if([url isEqualToString:self.smallArtworkUrl]) {
		self.smallArtworkImage = artworkImage;
		[self finishedLoadingSmallArtwork];
	}
	if([url isEqualToString:self.largeArtworkUrl]) {
		self.largeArtworkImage = artworkImage;
		[self finishedLoadingLargeArtwork];
	}
}

- (void)didReceiveMemoryWarning {
	[smallArtworkImage release]; smallArtworkImage = nil;
	[largeArtworkImage release]; largeArtworkImage = nil;
}

- (void)didTurnIntoFault {
	[smallArtworkImage release]; smallArtworkImage = nil;
	[largeArtworkImage release]; largeArtworkImage = nil;
}

@end
