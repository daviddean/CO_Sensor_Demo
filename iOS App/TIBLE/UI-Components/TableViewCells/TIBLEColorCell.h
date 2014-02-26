/*
 *  TIBLEColorCell.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <UIKit/UIKit.h>

@class TIBLEColorCell;

@protocol TIBLEColorCellDelegate <NSObject>

/**
 * Notifies the receiver the color button has been selected
 *
 * @param cell The cell where the color button is located
 */
- (void) colorButtonSelectedWithCell:(TIBLEColorCell *)cell;

@end

@interface TIBLEColorCell : UITableViewCell

- (IBAction)chooseColorButton:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *textTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *colorButton;
@property (weak, nonatomic) id<TIBLEColorCellDelegate> delegate;

@end
