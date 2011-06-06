//
//  BrowserController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-28.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerController.h"


@interface BrowserController : PlayerController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
	UIPopoverController *popoverController;
	IBOutlet UIToolbar *browserBar;
}

@property (nonatomic, retain) IBOutlet UIPopoverController *popoverController;

@end
