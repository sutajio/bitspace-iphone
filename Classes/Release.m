//
//  Release.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "Release.h"


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

-(void)fetchSmallArtwork {
//	ArtworkLoader *artworkLoader = [[[ArtworkLoader alloc] init] autorelease];
//	artworkLoader.url = release.smallArtworkUrl;
//	[self.operationQueue addOperation:artworkLoader];
}

@end
