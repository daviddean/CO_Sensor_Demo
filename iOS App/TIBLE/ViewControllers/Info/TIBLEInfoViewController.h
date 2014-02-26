/*
 *  TIBLEInfoViewController.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

/**
* This class displays copyright message,
* App about message,
* and links to TI's sensor products.
*/

#import <UIKit/UIKit.h>
#import "TIBLEStretchableImageView.h"
#import "TIBLEAlertWindow.h"

@interface TIBLEInfoViewController : UIViewController

@property (strong, nonatomic) IBOutlet TIBLEAlertWindow *alertWindow;
@property (weak, nonatomic) IBOutlet TIBLEStretchableImageView *stretchableAlertBackgroundImageView;
@property (weak, nonatomic) IBOutlet TIBLEStretchableImageView *stretchableAlertContentBackgroundImageView;

@property (weak, nonatomic) IBOutlet UIButton *powerButton;
@property (weak, nonatomic) IBOutlet UIButton *analogButton;
@property (weak, nonatomic) IBOutlet UIButton *processingButton;

@end
