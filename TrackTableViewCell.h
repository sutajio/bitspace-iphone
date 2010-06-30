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
}

@property (readwrite, assign) Track *track;

@end