/*
 *  TIBLEGraphDisplaySettingsViewController.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

/**
 * This class allows the user to modify values used when 
 * display the graph.
 */

#import <UIKit/UIKit.h>
#import "TIBLESensorProfile.h"
#import "NEOColorPickerViewController.h"

@interface TIBLEGraphDisplaySettingsViewController : UIViewController <NEOColorPickerViewControllerDelegate>

@end
