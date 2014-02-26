/*
 *  TIBLEHeaderView.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEHeaderView.h"
#import "TIBLEUIConstants.h"

@implementation TIBLEHeaderView

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
	
        CGRect frame = CGRectMake(10, 0, self.bounds.size.width, self.bounds.size.height);
        self.titleLabel = [[UILabel alloc] initWithFrame:frame];
        self.titleLabel.font = [UIFont fontWithName:TIBLE_APP_FONT_NAME size:TIBLE_APP_FONT_H3_HEADER_SIZE];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
    }
    
    return self;
}

- (void) setTitleString:(NSString *)title{

    self.titleLabel.text = title;
}

@end
