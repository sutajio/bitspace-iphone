//
//  BiographyController.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-08-17.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import "BiographyController.h"
#import "Artist.h"


@implementation BiographyController

@synthesize theArtist;

- (void)showWebsite {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:theArtist.website]];
}

- (void)updateArtwork {
	if(theArtist.largeArtworkUrl == nil) {
		[activityIndicatorView stopAnimating];
	} else {
		if(theArtist.largeArtworkImage) {
			[activityIndicatorView stopAnimating];
			[UIView beginAnimations:@"BiographyArtwork" context:nil];
			[UIView setAnimationDuration:0.5f];
			[UIView setAnimationBeginsFromCurrentState:YES];
			artworkView.alpha = 1.0f;
			artworkView.image = theArtist.largeArtworkImage;
			[UIView commitAnimations];
		}
	}
}

- (void)updateBiography {
	if([NSThread isMainThread]) {
		[biographyView loadHTMLString:[NSString stringWithFormat:@"<style>html,body{margin:0;padding:0;background:#ccc;color:#000;};</style><div style=\"width:300px;height:300px;outline:1px inset #fff;margin:10px;\"></div><div style=\"margin:10px;font:14px/1.6em Georgia, serif;text-shadow:#fff 0px 1px 1px;\">%@</div>", theArtist.biography ? theArtist.biography : @""] baseURL:nil];
	} else {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		theArtist.biography;
		[pool release];
		[self performSelectorOnMainThread:@selector(updateBiography) withObject:nil waitUntilDone:NO];
	}
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Watch for the artwork to load
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateArtwork) name:@"finishedLoadingLargeArtwork" object:nil];
	
	self.navigationItem.title = @"Biography";
	
	if(theArtist.website) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Website" style:UIBarButtonItemStylePlain target:self action:@selector(showWebsite)];
	}
	
	[self performSelectorInBackground:@selector(updateBiography) withObject:nil];
	[self updateArtwork];
	
	[[biographyView _documentView] addSubview:artworkView];
}

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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
    [super dealloc];
}


@end
