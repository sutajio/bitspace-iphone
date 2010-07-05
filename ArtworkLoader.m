//
//  ArtworkLoader.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "ArtworkLoader.h"
#import "Release.h"


@implementation ArtworkLoader

@synthesize url, delegate;

-(void)main {
	NSLog(@"ArtworkLoader#main");
	NSURL *artworkUrl = [NSURL URLWithString:self.url];
	NSData *artworkData = [NSData dataWithContentsOfURL:artworkUrl];
	UIImage *artworkImage = [UIImage imageWithData:artworkData];
	[delegate loaderDidFinishLoadingArtwork:artworkImage fromURL:self.url];
}

@end
