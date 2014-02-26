/*
 *  TIBLEGraphViewController.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <UIKit/UIKit.h>
#import "TIBLESensorModel.h"
#import "TIBLEStretchableImageView.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface TIBLEGraphViewController : UIViewController

- (MFMailComposeViewController *) sharedEmailControllerWithGraphData;
- (UIActivityViewController *) sharedActivityControllerWithGraphData;
- (void) setIsPaused:(BOOL)isPaused;

@end
