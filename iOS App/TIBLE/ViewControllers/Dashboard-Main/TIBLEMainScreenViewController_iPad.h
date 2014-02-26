/*
 *  TIBLEMainScreenViewController_iPad.h
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
#import "TIBLEGraphViewController.h"

@interface TIBLEMainScreenViewController_iPad : UIViewController

@property (nonatomic, strong) TIBLESensorInfoViewController * sensorInfoVC;
@property (nonatomic, strong) TIBLEProgressViewController * progressVC;
@property (nonatomic, strong) TIBLEGraphViewController * graphVC;
@property (strong, nonatomic) IBOutlet UIView *mainScreenParentContainerView;

@end
