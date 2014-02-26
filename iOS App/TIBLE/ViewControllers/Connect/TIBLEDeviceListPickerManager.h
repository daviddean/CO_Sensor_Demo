/*
 *  TIBLEDeviceListPickerManager.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
#import "TIBLEDeviceListPickerTableViewController.h"
#import "TIBLEStretchableImageView.h"
#import "TIBLEAlertWindow.h"

@protocol TIBLEDevicesListPickerManagerDelegate <NSObject>

- (void) devicePickerDidShow;
- (void) devicePickerDidHide;

@end

@interface TIBLEDeviceListPickerManager : NSObject


@property (strong, nonatomic) IBOutlet TIBLEAlertWindow *devicesListAlertWindow;
- (IBAction)dismissDevicesListAlert:(id)sender;
- (void) showDevicesListAlert;
@property (weak, nonatomic) IBOutlet UIView *tableContainerView;
@property (strong, nonatomic) IBOutlet TIBLEDeviceListPickerTableViewController * tableVC;
@property (weak, nonatomic) IBOutlet TIBLEStretchableImageView *stretchableAlertBackgroundImageView;
@property (weak, nonatomic) IBOutlet TIBLEStretchableImageView *stretchableAlertContentBackgroundImageView;
@property (weak, nonatomic) id<TIBLEDevicesListPickerManagerDelegate> delegate;

- (BOOL) isDevicesListAlertShowing;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
