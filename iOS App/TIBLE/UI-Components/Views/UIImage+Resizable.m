/*
 *  UIImage+Resizable.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "UIImage+Resizable.h"

@implementation UIImage (Resizable)

- (UIImage *) duplicateImageWithCapInsets: (UIEdgeInsets) edgeInsets
{
	UIImage *image = nil;
	
	float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	
	if (osVersion < 6.0) {
		
		image = [self resizableImageWithCapInsets:edgeInsets]; //tile
		
	} else {
		
		image = [self resizableImageWithCapInsets:edgeInsets
									 resizingMode:UIImageResizingModeStretch];
	}
	
	return image;
}

- (UIImage *) duplicateImageWithLeftCapWidth: (NSInteger) leftCap
							 andTopCapHeight: (NSInteger) topCap{
	
	UIImage *image = nil;
	
	float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	
	if (osVersion < 6.0) {
		
		image = [self stretchableImageWithLeftCapWidth:leftCap
										  topCapHeight:topCap]; //stretch
	}
	else{
		
		UIEdgeInsets insets = UIEdgeInsetsMake(topCap, leftCap, topCap, leftCap);
		
		image = [self resizableImageWithCapInsets:insets
									 resizingMode:UIImageResizingModeStretch];
	}
	
	return image;
}

@end
