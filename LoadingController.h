//
//  LoadingController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-30.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadingController : UIViewController {
	IBOutlet UIView *roundedRect;
	IBOutlet UIActivityIndicatorView *activityIndicatorView;
	IBOutlet UIProgressView *progressView;
}

@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, readonly) UIProgressView *progressView;

@end
