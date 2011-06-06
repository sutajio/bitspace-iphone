//
//  CollectionGridViewCell.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2011-02-02.
//  Copyright 2011 Sutajio. All rights reserved.
//

#import "CollectionGridViewCell.h"
#import "Release.h"
#import "Track.h"
#import "GradientView.h"
#import "Theme.h"


@implementation CollectionGridViewCell

@synthesize release;

- (id)initWithReuseIdentifier:(NSString *)anIdentifier {
    self = [super initWithReuseIdentifier:anIdentifier];
    if (self) {
		
		NSLog(@"Cell");
		artworkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[artworkButton setBackgroundImage:[UIImage imageNamed:@"cover-art-large.jpg"] forState:UIControlStateNormal];
		[self addSubview:artworkButton];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:@"finishedLoadingSmallArtwork" object:nil];
    }
    return self;
}


- (void)updateState:(NSNotification *)notification {
	if(notification && [notification object] != release)
		return;
	self.release = release;
}


- (void)setRelease:(Release *)value {
	release = value;
	
	//self.textLabel.text = self.release.title;
	//self.detailTextLabel.text = self.release.artist;
	
	artworkButton.frame = CGRectMake(15.0f, 15.0f, CGRectGetWidth(self.frame)-30.0f, CGRectGetHeight(self.frame)-30.0f);
	[artworkButton setBackgroundImage:[UIImage imageNamed:@"cover-art-large.jpg"] forState:UIControlStateNormal];
	if(release.smallArtworkImage) {
		//artworkButton.hidden = NO;
		[artworkButton setBackgroundImage:self.release.smallArtworkImage forState:UIControlStateNormal];
		[self bringSubviewToFront:artworkButton];
		if(isWaitingForArtwork == YES) {
//			artworkButton.alpha = 0.0f;
//			[UIView beginAnimations:@"ShowArtwork" context:nil];
//			[UIView setAnimationDuration:0.4f];
//			[UIView setAnimationBeginsFromCurrentState:NO];
//			artworkButton.alpha = 1.0f;
//			[UIView commitAnimations];
			isWaitingForArtwork = NO;
		}
	} else {
		if(release.smallArtworkLoader) {
			isWaitingForArtwork = YES;
		}
		//artworkButton.hidden = YES;
	}
	
	//bgView.backgroundColor = [Theme backgroundColor];
	//bgView.gradientEnabled = NO;
	
	[self setNeedsLayout];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


@end
