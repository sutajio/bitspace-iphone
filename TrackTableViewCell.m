//
//  TrackTableViewCell.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-18.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "TrackTableViewCell.h"
#import "Track.h"


@implementation TrackTableViewCell

@synthesize track;

- (void)setTrack:(Track *)value {
	track = value;
	self.textLabel.text = track.title;
	self.detailTextLabel.text = track.artist;
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	UIButton *loveButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
	if(track.lovedAt) {
		[loveButton setImage:[UIImage imageNamed:@"love-on.png"] forState:UIControlStateNormal];
	} else {
		[loveButton setImage:[UIImage imageNamed:@"love-off.png"] forState:UIControlStateNormal];
	}
	self.accessoryView = loveButton;
}

@end
