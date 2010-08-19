//
//  BiographyController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-08-17.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Artist;

@interface BiographyController : UIViewController {
	Artist *theArtist;
	IBOutlet UIImageView *artworkView;
	IBOutlet UIWebView *biographyView;
	IBOutlet UIActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic, retain) Artist *theArtist;

@end
