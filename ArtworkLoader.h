//
//  ArtworkLoader.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ArtworkLoader : NSOperation {
	NSString *url;
}

@property (nonatomic, retain) NSString *url;

@end
