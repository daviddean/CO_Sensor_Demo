/*
 *  TIBLESelectableCell.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <UIKit/UIKit.h>

@interface TIBLESelectableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel * cellTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel * cellValueLabel;
@property (weak, nonatomic) IBOutlet UIImageView * checkmark;

@end
