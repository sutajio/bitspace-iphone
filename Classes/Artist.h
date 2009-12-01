//
//  Artist.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2009-12-01.
//  Copyright 2009 Koneko Collective Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Artist : NSObject {
	NSString *name;
	NSString *artistId;
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *artistId;
@end
