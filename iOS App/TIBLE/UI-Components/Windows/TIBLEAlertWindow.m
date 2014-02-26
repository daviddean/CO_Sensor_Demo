/*
 *  TIBLEAlertWindow.m
 *  TI BLE Sensor App
 *  05/06/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEAlertWindow.h"

#define kDegrees0  0.0f
#define kDegrees90  90.0f
#define kDegrees180 180.0f

#define DegreesToRadians(degrees) (degrees * M_PI / kDegrees180)

@implementation TIBLEAlertWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	
    if (self) {
		
		[self registerForDeviceOrientationNotifications];
    }
	
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	
    if (self) {
		[self registerForDeviceOrientationNotifications];
	}
	
	return self;
}

- (void) registerForDeviceOrientationNotifications{
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(statusBarDidChangeFrame:)
												 name:UIApplicationDidChangeStatusBarOrientationNotification
											   object:nil];

}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation {
	
    switch (orientation) {
			
        case UIInterfaceOrientationLandscapeLeft:
            return CGAffineTransformMakeRotation(-DegreesToRadians(kDegrees90));
			
        case UIInterfaceOrientationLandscapeRight:
            return CGAffineTransformMakeRotation(DegreesToRadians(kDegrees90));
			
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(DegreesToRadians(kDegrees180));
			
        case UIInterfaceOrientationPortrait:
        default:
            return CGAffineTransformMakeRotation(DegreesToRadians(kDegrees0));
    }
}

- (void)statusBarDidChangeFrame:(NSNotification *)notification {
	
	[self setOrientationToCurrentDeviceOrientation];
}

- (void) setOrientationToCurrentDeviceOrientation{
	
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	
    [self setTransform:[self transformForOrientation:orientation]];
}

@end
