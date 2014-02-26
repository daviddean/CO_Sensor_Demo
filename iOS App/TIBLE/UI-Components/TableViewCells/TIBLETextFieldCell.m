/*
 *  TIBLETextFieldCell.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLETextFieldCell.h"
#import "TIBLESensorConstants.h"
#import "TIBLEUIConstants.h"

@implementation TIBLETextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.isNonZeroValue = NO;
		self.isStringValue = YES;
    }
    
    return self;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    
//    [super setSelected:selected animated:animated];
//    
//    if (selected) {
//        [self.valueTextField becomeFirstResponder];
//    }
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.valueTextField resignFirstResponder];
    
	return YES;
}

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
	BOOL shouldEndEditing = YES;
	
    [self resignFirstResponder];
    
	if(textField.text == nil){
		return shouldEndEditing;
	}
	
	if (self.isNonZeroValue == YES) {
        
        float value = [self.valueTextField.text floatValue];
        
		if (self.displayAlertInputMustBeNonZeroValue == YES) {
            
            shouldEndEditing = NO;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"Settings.Alert.InputMustBeNonZeroValue", nil)
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"Alert.OK", nil), nil];
            [alert show];
            
            value = TIBLE_SENSOR_DEFAULT_DENOMINATOR_VALUE;
		}
		
		self.valueTextField.text = [NSString stringWithFormat:@"%.2f", value];
		
    }
	else if(self.isUnsignedIntegerValue == YES){
        
        uint32_t value = [self.valueTextField.text intValue];
		
		if(self.displayAlertInputMustBeUnsignedInteger == YES){
			
			shouldEndEditing = NO;
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
															message:NSLocalizedString(@"Settings.Alert.InputMustBeUnsignedInteger", nil)
														   delegate:self
												  cancelButtonTitle:nil
												  otherButtonTitles:NSLocalizedString(@"Alert.OK", nil), nil];
			[alert show];
			
            value = TIBLE_SENSOR_DEFAULT_UNSIGNED_INTEGER_VALUE;
		}
		
		self.valueTextField.text = [NSString stringWithFormat:@"%u", value];
        
	}
    else if(self.isFloatValue == YES){
		
		//check if there are letters in the input.
		if([self.valueTextField.text rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location != NSNotFound) {
			
			shouldEndEditing = NO;
			
			//if found letters, show alert
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
															message:NSLocalizedString(@"Settings.Alert.InputMustBeFloat", nil)
														   delegate:self
												  cancelButtonTitle:nil
												  otherButtonTitles:NSLocalizedString(@"Alert.OK", nil), nil];
			[alert show];
		}
		
		//default to 0 if it contains letters or other non-numeric characters.
		NSString * displayString = [NSString stringWithFormat:@"%.2f",
									[self.valueTextField.text floatValue]];
		
        // used with calibration value cell
        if ([self.valueTextField.placeholder isEqualToString:NSLocalizedString(@"Settings.Input.DoNotCalibrate.String", @"No calibration")]         // our place holder is set to "No calibration"
                && [self.valueTextField.text isEqualToString:@""]                                                                                   // our text field is empty
                && [self.textTitleLabel.text isEqualToString:NSLocalizedString(@"Settings.Graph.Sensor.Calibration.Value", @"sensor calibration")]) // we are in the calibration cell
        {
            // verify that we arent replacing "No calibration" with zero
            return shouldEndEditing;
        }
        
        self.valueTextField.placeholder = nil;
        
		self.valueTextField.text = displayString;
		
	}
	else if(self.isStringValue == YES){
		
		//do nothing.
	}
    
    return shouldEndEditing;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
	[self.delegate textFieldDidEndEditingWithCell:self];
	
	[self.delegate textFieldUpdatedWithCell:self];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
	[self.delegate textFieldDidBeginEditingWithCell:self];
	
    [self.delegate textFieldSelectedWithCell:self];
}

- (BOOL) displayAlertInputMustBeNonZeroValue{
	
	BOOL displayAlert = NO;
	
    if (self.isNonZeroValue) {
		
		float_t value = [self.valueTextField.text floatValue];
		
		if(value == 0){
			
			displayAlert = YES;
			
			return displayAlert;
		}
	}
	
	return displayAlert;
}

- (BOOL) displayAlertInputMustBeUnsignedInteger{
	
	BOOL displayAlert = NO;
	
	if (self.isUnsignedIntegerValue){
		
		//float value
		float_t value = [self.valueTextField.text floatValue];
		
		//unsigned integer value
		uint32_t uintValue = (uint32_t) value;
		
		if(value < 0 || value != uintValue ||
           [self.valueTextField.text rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound) {
			
            displayAlert = YES;
			
            return displayAlert;
		}
	}
    
	return displayAlert;
}

- (void) makeTextFieldFirstResponder {
    
    [self.valueTextField becomeFirstResponder];
}

@end
