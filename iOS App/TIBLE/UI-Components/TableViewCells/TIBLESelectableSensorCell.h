/*
 *  TIBLESelectableSensorCell.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <UIKit/UIKit.h>

@interface TIBLESelectableSensorCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel * cellAddressLabel;
@property (weak, nonatomic) IBOutlet UIImageView * checkmark;
@property (weak, nonatomic) IBOutlet UILabel *cellNameLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *connectingIndicator;

@end
