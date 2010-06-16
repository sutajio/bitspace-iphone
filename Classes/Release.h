//
//  Release.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Release : NSManagedObject

	@property (nonatomic, retain) NSString *title;
	@property (nonatomic, retain) NSString *artist;
	@property (nonatomic, retain) NSString *year;
	@property (nonatomic, retain) NSString *url;
	@property (nonatomic, retain) NSDate *createdAt;
	@property (nonatomic, retain) NSString *smallArtworkUrl;
	@property (nonatomic, retain) NSString *mediumArtworkUrl;
	@property (nonatomic, retain) NSString *largeArtworkUrl;
	@property (nonatomic, retain) NSData *smallArtwork;
	@property (nonatomic, retain) NSData *mediumArtwork;
	@property (nonatomic, retain) NSData *largeArtwork;

-(void)fetchSmallArtwork;

@end
