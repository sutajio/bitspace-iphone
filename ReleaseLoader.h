//
//  ReleaseLoader.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-17.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate, Release;

@interface ReleaseLoader : NSOperation {
	AppDelegate *appDelegate;
	Release *release;
}

@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) Release *release;

@end
