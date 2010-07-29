//
//  ReleaseTableViewCell.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-28.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Release;

@interface ReleaseTableViewCell : UITableViewCell {
	Release *release;
	UIImageView *artworkImageView;
	UIProgressView *downloadProgressView;
	BOOL isWaitingForArtwork;
}

@property (readwrite, assign) Release *release;

- (void)showActivity;
- (void)hideActivity;

@end
