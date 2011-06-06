//
//  PickerSheet.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2011-06-06.
//  Copyright 2011 Sutajio. All rights reserved.
//

#import "PickerSheet.h"


@implementation PickerSheet

@synthesize delegate;

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if (animationID && [animationID isEqualToString:@"PickerSheetHideAnimation"]) {
		[window release];
	}
}

- (void)showInView:(UIView *)view {
	[self showInView:view animated:YES];
}

- (void)showInView:(UIView *)view animated:(BOOL)animated {
	[self retain];
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	window.windowLevel = UIWindowLevelStatusBar;
	[window makeKeyAndVisible];
	
	shade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	shade.backgroundColor = [UIColor blackColor];
	shade.alpha = 0.0f;
	[window addSubview:shade];
	
	[window addSubview:self.view];
	
	if (animated) {
		shade.alpha = 0.0f;
		self.view.frame = CGRectMake(0, 480, 320, 258);
		[UIView beginAnimations:@"PickerSheetShowAnimation" context:nil];
		[UIView setAnimationDelegate:self];
		shade.alpha = 0.5f;
		self.view.frame = CGRectMake(0, 222, 320, 258);
		[UIView commitAnimations];
	} else {
		shade.alpha = 0.5f;
		self.view.frame = CGRectMake(0, 222, 320, 258);
	}
}

- (void)dismissWithAnimation:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:@"PickerSheetHideAnimation" context:nil];
		[UIView setAnimationDelegate:self];
		shade.alpha = 0.0f;
		self.view.frame = CGRectMake(0, 480, 320, 258);
		[UIView	setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView commitAnimations];
	} else {
		[window release];
	}
	[self release];
}

- (IBAction)cancel:(id)sender {
	[self dismissWithAnimation:YES];
	if (self.delegate) {
		[self.delegate pickerSheetCancel:self];
	}
}

- (IBAction)done:(id)sender {
	[self dismissWithAnimation:YES];
	if (self.delegate) {
		[self.delegate pickerSheet:self pickedObjects:pickedObjects];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	pickedObjects = [[NSMutableArray alloc] initWithCapacity:0];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [shade release];
	[pickedObjects release];
}


- (void)dealloc {
    [super dealloc];
}


@end
