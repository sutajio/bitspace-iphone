//
//  Artist.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-07-13.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Artist : NSManagedObject {

}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *sectionName;
@property (nonatomic, retain) NSNumber *archived;

@end
