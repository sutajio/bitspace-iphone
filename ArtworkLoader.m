//
//  ArtworkLoader.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "ArtworkLoader.h"


@implementation ArtworkLoader

@synthesize url;

-(void)main {
	NSURL *artworkUrl = [NSURL URLWithString:self.url];
	NSData *artwork = [NSData dataWithContentsOfURL:artworkUrl];
}

@end
