/*
 *  TIBLEFormulaSettingsViewController.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <UIKit/UIKit.h>
#import "TIBLEStretchableImageView.h"

@class TIBLEHeaderView;

/**
 * This class allows the user to modify the formula values
 * used with the sensor's calculations.
 */

@interface TIBLEFormulaSettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet TIBLEHeaderView * headerSensorFormula;
@property (weak, nonatomic) IBOutlet TIBLEStretchableImageView *stretchableBackgroundFormulaSettingsImageView;

@end
