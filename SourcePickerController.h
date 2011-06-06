//
//  SourcePickerController.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2011-06-06.
//  Copyright 2011 Sutajio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerSheet.h"


@interface SourcePickerController : PickerSheet {
	IBOutlet UIPickerView *picker;
	NSString *selectedSource;
}

@property (nonatomic, retain) NSString *selectedSource;

- (IBAction)valueChanged:(id)sender;

@end
