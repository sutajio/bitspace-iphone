//
//  ReleaseController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2010-06-16.
//  Copyright 2010 Koneko Collective Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Release;

@interface ReleaseController : UITableViewController {
	Release *release;
	NSManagedObjectContext *managedObjectContext;
	IBOutlet UIImageView *artworkImage;
}

@property (nonatomic, retain) Release *release;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
