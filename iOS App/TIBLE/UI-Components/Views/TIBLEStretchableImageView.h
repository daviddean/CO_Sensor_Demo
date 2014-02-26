/*
 *  TIBLEStretchableImageView.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <UIKit/UIKit.h>

@interface TIBLEStretchableImageView : UIView

@property (nonatomic, strong) UIImageView * imageView;

- (void) setImageForName: (NSString *) imageName
			   andInsets:(UIEdgeInsets) edgeInsets;

- (void) setImageForName: (NSString *) imageName
		withLeftCapWidth: (NSInteger) leftCap
		 andTopCapHeight: (NSInteger) topCap;

@end
