/*
 *  TIBLEClearBackgroundView.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEClearBackgroundView.h"

@implementation TIBLEClearBackgroundView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	
    if (self) {

		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
