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
	IBOutlet UIBarButtonItem *cancelButton;
	
	AppDelegate *appDelegate;
}

@property (nonatomic, retain) AppDelegate *appDelegate;

- (IBAction)authenticate:(id)sender;
- (IBAction)focusPasswordField:(id)sender;
- (IBAction)dismissSignInScreen:(id)sender;

@end
