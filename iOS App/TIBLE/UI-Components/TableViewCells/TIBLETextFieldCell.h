/*
 *  TIBLETextFieldCell.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <UIKit/UIKit.h>

@class TIBLETextFieldCell;

@protocol TIBLETextFieldCellDelegate <NSObject>
@optional

/**
 * Notifies the receiver that a text field has been updated
 *
 * @param cell The cell where the text field is located
*/
- (void) textFieldUpdatedWithCell:(TIBLETextFieldCell *)cell;

/**
 * Notifies the receiver that a text field has been selected
 *
 * @param cell The cell where the text field is located
 */
- (void) textFieldSelectedWithCell:(TIBLETextFieldCell *)cell;

- (void) textFieldDidEndEditingWithCell:(TIBLETextFieldCell *)cell;
- (void) textFieldDidBeginEditingWithCell:(TIBLETextFieldCell *)cell;

@end

@interface TIBLETextFieldCell : UITableViewCell <UITextFieldDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *valueTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *textTitleLabel;

@property (weak, nonatomic) id<TIBLETextFieldCellDelegate> delegate;

@property BOOL isNonZeroValue; /*!< If set to true, this field must be a  non-zero numeric value */
@property BOOL isUnsignedIntegerValue; /*!< If set to true, this field must be a >= 0 .*/
@property BOOL isStringValue;
@property BOOL isFloatValue;

- (BOOL) displayAlertInputMustBeNonZeroValue;
- (BOOL) displayAlertInputMustBeUnsignedInteger;

- (void) makeTextFieldFirstResponder;

@end
