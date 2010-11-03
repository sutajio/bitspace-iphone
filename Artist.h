//
//  Artist.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-13.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtworkLoader.h"


@interface Artist : NSManagedObject <ArtworkLoaderDelegate> {
	UIImage *smallArtworkImage;
	UIImage *largeArtworkImage;
	ArtworkLoader *smallArtworkLoader;
	ArtworkLoader *largeArtworkLoader;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *sortName;
@property (nonatomic, retain) NSString *sectionName;
@property (nonatomic, retain) NSString *artistType;
@property (nonatomic, retain) NSString *beginDate;
@property (nonatomic, retain) NSString *endDate;
@property (nonatomic, retain) NSString *website;
@property (nonatomic, retain) NSString *smallArtworkUrl;
@property (nonatomic, retain) NSString *largeArtworkUrl;
@property (nonatomic, retain) NSString *biographyUrl;
@property (nonatomic, retain) NSNumber *archived;
@property (nonatomic, retain) NSSet *releases;

@property (nonatomic, retain) UIImage *smallArtworkImage;
@property (nonatomic, retain) UIImage *largeArtworkImage;
@property (nonatomic, retain) ArtworkLoader *smallArtworkLoader;
@property (nonatomic, retain) ArtworkLoader *largeArtworkLoader;

- (void)didReceiveMemoryWarning;

@end
