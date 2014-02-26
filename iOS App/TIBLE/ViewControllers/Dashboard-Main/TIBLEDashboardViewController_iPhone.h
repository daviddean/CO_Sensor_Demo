/*
 *  TIBLEDashboardViewController_iPhone.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <UIKit/UIKit.h>
#import "TIBLESensorInfoViewController.h"
#import "TIBLEProgressViewController.h"
#import "TIBLEStretchableImageView.h"

@interface TIBLEDashboardViewController_iPhone : UIViewController

@property (nonatomic, strong) TIBLESensorInfoViewController * sensorInfoVC;
@property (nonatomic, strong) TIBLEProgressViewController * progressVC;


@end
