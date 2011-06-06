//
//  SourcePickerController.m
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2011-06-06.
//  Copyright 2011 Sutajio. All rights reserved.
//

#import "SourcePickerController.h"


@implementation SourcePickerController

@synthesize selectedSource;

- (void)updatePickedObjects {
	[pickedObjects removeAllObjects];
	//[pickedObjects addObject:picker.selec];
}

- (IBAction)valueChanged:(id)sender {
	[self updatePickedObjects];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	if (selectedSource) {
		//[datePicker setDate:selectedDate animated:NO];
	}
	[self updatePickedObjects];
}

@end
