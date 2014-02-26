/*
 *  TIBLESelectableSensorCell.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLESelectableSensorCell.h"

@implementation TIBLESelectableSensorCell

- (id) initWithCoder:(NSCoder *)aDecoder{
	
	self = [super initWithCoder:aDecoder];
	
	if(self){

	}
	
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
