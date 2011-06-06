//
//  TrackTableViewCell.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-18.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Track, GradientView;

@interface TrackTableViewCell : UITableViewCell {
	Track *track;
	NSInteger index;
	BOOL showAlbumArtist;
	GradientView *bgView;
	UIImageView *playingImage;
	UILabel *trackNrLabel;
	UILabel *textLabel;
	UILabel *detailTextLabel;
	UIButton *loveButton;
	UIActivityIndicatorView *downloadActivityIndicator;
}

@property (readwrite, assign) Track *track;
@property (readwrite, assign) NSInteger index;
@property (readwrite, assign) BOOL showAlbumArtist;

@end
