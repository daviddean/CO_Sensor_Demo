/*
 *  TIBLEConnectViewController.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

/**
* This class displays a list of all the available sensors
* that the App can connect to.
*/

#import <UIKit/UIKit.h>
#import "TIBLEHeaderView.h"
#import "TIBLESensorModel.h"
#import "TIBLEDeviceListPickerTableViewController.h"
#import "TIBLEStretchableImageView.h"

@interface TIBLEConnectViewController : UIViewController

@property (weak, nonatomic) IBOutlet TIBLEHeaderView * headerConnectedToSensor;
@property (weak, nonatomic) IBOutlet TIBLEHeaderView * headerDiscoveredSensors;

@property (nonatomic, strong) TIBLESensorModel * sensor;
@property (weak, nonatomic) IBOutlet UILabel *labelNoSensorConnected;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameValueLabel;
@property (weak, nonatomic) IBOutlet UIView *tableContainerView;
@property (strong, nonatomic) IBOutlet TIBLEDeviceListPickerTableViewController *tableVC;
@property (weak, nonatomic) IBOutlet TIBLEStretchableImageView *stretchableSensorInfoBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *editSensorName; /*!< When selected, the user may edit the name of the device.
                                                                *   This does not write the name to the sensor, it only keeps a local
                                                                *   reference. The same name may be assigned to multiple devices.
                                                                *   Saved device names are matched using the sensor's unique UUID.
                                                                */

@end
