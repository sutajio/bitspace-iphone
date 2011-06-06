//
//  PickerSheet.h
//  bitspace-iphone
//
//  Created by Niklas Holmgren on 2011-06-06.
//  Copyright 2011 Sutajio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PickerSheet;

@protocol PickerSheetProtocol
- (void)pickerSheet:(PickerSheet *)pickerSheet pickedObjects:(NSArray *)objects;
- (void)pickerSheetCancel:(PickerSheet *)pickerSheet;
@end

@interface PickerSheet : UIViewController {
	id <PickerSheetProtocol> delegate;
	UIWindow *window;
	UIView *shade;
	NSMutableArray *pickedObjects;
}

@property (assign) id <PickerSheetProtocol> delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

- (void)showInView:(UIView *)view;
- (void)showInView:(UIView *)view animated:(BOOL)animated;
- (void)dismissWithAnimation:(BOOL)animated;

@end
