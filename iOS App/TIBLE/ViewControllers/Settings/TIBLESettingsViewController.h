/*
 *  TIBLESettingsViewController.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

/**
 * This class responsible for managing user interaction with settings.
 * When no setting is created or selected, the settings provided by the sensor will be 
 * used by default. If a setting is selected and the user connects to a device, the selected setting
 * will be deselected and the settings provided by the sensor will be used.
 */

#import <UIKit/UIKit.h>
#import "TIBLEHeaderView.h"
#import "TIBLEStretchableImageView.h"

@interface TIBLESettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet TIBLEHeaderView * headerSettingsOptions;
@property (weak, nonatomic) IBOutlet TIBLEHeaderView * headerSaveSettings;
@property (weak, nonatomic) IBOutlet TIBLEStretchableImageView *stretchableSettingsViewControllerBackgroundImageView;

@end
