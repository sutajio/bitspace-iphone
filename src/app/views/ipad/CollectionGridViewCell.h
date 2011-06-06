//
//  CollectionGridViewCell.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2011-02-02.
//  Copyright 2011 Sutajio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTGridViewCell.h"


@class Release, GradientView;

@interface CollectionGridViewCell : DTGridViewCell {
	Release *release;
	GradientView *bgView;
	UIButton *artworkButton;
	UIProgressView *downloadProgressView;
	BOOL isWaitingForArtwork;
}

@property (readwrite, assign) Release *release;

@end
