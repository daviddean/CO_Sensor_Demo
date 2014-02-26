/*
 *  TIBLECheckmark.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLECheckmark.h"

@interface TIBLECheckmark (){
    
}

@property (nonatomic, strong) UIImageView * checkmarkCheckedImageView;
@property (nonatomic, strong) UIImageView * checkmarkNotCheckedImageView;

@end

@implementation TIBLECheckmark

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
		
		_checked = NO;
		
        _checkmarkCheckedImageView = [[UIImageView alloc] initWithImage:
									  [UIImage imageNamed:@"checkmark"]];
		_checkmarkNotCheckedImageView = [[UIImageView alloc] initWithImage:
										 [UIImage imageNamed:@"red_cross"]];
		
		_checkmarkCheckedImageView.hidden = YES;
		_checkmarkNotCheckedImageView.hidden = YES;
		
		_checkmarkCheckedImageView.contentMode = UIViewContentModeScaleAspectFit;
		_checkmarkNotCheckedImageView.contentMode = UIViewContentModeScaleAspectFit;
		
		self.backgroundColor = [UIColor clearColor];
    }
	
    return self;
}

- (void) setChecked:(BOOL) value{
	
	_checked = value;
	
	[self setNeedsDisplay];
}

- (void) layoutSubviews{
    
	self.checkmarkCheckedImageView.bounds = self.bounds;
	self.checkmarkNotCheckedImageView.bounds = self.bounds;
	
	float x1 = self.checkmarkCheckedImageView.bounds.size.width/2.0f;
	float y1 = self.checkmarkCheckedImageView.bounds.size.height/2.0f;
	self.checkmarkCheckedImageView.center = CGPointMake(x1, y1);
	
	float x2 = self.checkmarkNotCheckedImageView.bounds.size.width/2.0f;
	float y2 = self.checkmarkNotCheckedImageView.bounds.size.height/2.0f;

	self.checkmarkNotCheckedImageView.center = CGPointMake(x2, y2);
	
	[self addSubview:self.checkmarkCheckedImageView];
	[self addSubview:self.checkmarkNotCheckedImageView];
}

- (void)drawRect:(CGRect)rect
{
	self.checkmarkCheckedImageView.hidden = !self.checked;
	self.checkmarkNotCheckedImageView.hidden = self.checked;
}

@end
