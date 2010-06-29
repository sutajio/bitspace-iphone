//
//  SignInController.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-29.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "SignInController.h"
#import "AppDelegate.h"


@implementation SignInController

@synthesize appDelegate;


- (void)authenticate:(id)sender {
	if([appDelegate validateUsername:usernameTextField.text andPassword:passwordTextField.text] == YES) {
		[self dismissModalViewControllerAnimated:YES];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry, friend!" message:@"Invalid username or password."
													   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
		[alert show];
		[alert release];
	}
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
