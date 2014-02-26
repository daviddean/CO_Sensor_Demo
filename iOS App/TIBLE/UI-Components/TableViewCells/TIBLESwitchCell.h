/*
 *  TIBLESwitchCell.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <UIKit/UIKit.h>

@class TIBLESwitchCell;

@protocol  TIBLESwitchCellDelegate <NSObject>

/**
 * Notifies the receiver that a switch has been triggered
 *
 * @param cell The cell where the switch is located
 */
- (void) switchFlippedInCell:(TIBLESwitchCell *)cell;

@end

@interface TIBLESwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *textTitleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *cellSwitch;
@property (weak, nonatomic) id<TIBLESwitchCellDelegate> delegate;

- (IBAction)switchTriggered:(id)sender;

@end
