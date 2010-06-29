//
//  SignInController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-29.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface SignInController : UIViewController {
	IBOutlet UITextField *usernameTextField;
	IBOutlet UITextField *passwordTextField;
	
	AppDelegate *appDelegate;
}

@property (nonatomic, retain) AppDelegate *appDelegate;

- (IBAction)authenticate:(id)sender;

@end
