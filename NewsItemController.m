//
//  NewsItemController.m
//  bitspace-iphone
//
//  Created by Fredrik Lundqvist on 11/9/10.
//  Copyright 2010 Sutajio. All rights reserved.
//

#import "NewsItemController.h"
#import "AppDelegate.h"


@implementation NewsItemController

@synthesize appDelegate, webView, link;

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Booom!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSURL *url = [NSURL URLWithString:link];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[webView loadRequest:requestObj];
}

/*- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}*/

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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[webView release];
    [super dealloc];
}


@end
