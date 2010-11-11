//
//  NewsItemController.h
//  bitspace-iphone
//
//  Created by Fredrik Lundqvist on 11/9/10.
//  Copyright 2010 Sutajio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface NewsItemController : UIViewController <UIWebViewDelegate> {
	AppDelegate *appDelegate;
	IBOutlet UIWebView *webView;
	NSString *link;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *link;

@end
