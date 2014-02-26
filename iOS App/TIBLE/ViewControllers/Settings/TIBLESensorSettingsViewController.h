/*
 *  TIBLESensorSettingsViewController.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

/**
 * This class allows the user to view and modify the internal settings for connected sensor.
 */

#import <UIKit/UIKit.h>
#import "TIBLESensorModel.h"

@interface TIBLESensorSettingsViewController : UIViewController

@property (strong, nonatomic) NSArray *content; /*!< Keeps track of all available setting that can be written to the sensor */

@property (nonatomic) int childIndex; /*!< The index of the setting that was selected. It is used to display the values that the user wishes to view/edit */

/**
 * This method writes all the values of a saved setting to the connected sensor
 * when said setting is selected.
 */
- (void)writeAllValues;

@end
