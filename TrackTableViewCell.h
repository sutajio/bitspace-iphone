//
//  TrackTableViewCell.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-18.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Track;

@interface TrackTableViewCell : UITableViewCell {
	Track *track;
	UIView *bgView;
	UILabel *trackNrLabel;
	UILabel *textLabel;
	UILabel *detailTextLabel;
	UIButton *loveButton;
	UIActivityIndicatorView *downloadActivityIndicator;
}

@property (readwrite, assign) Track *track;

@end
