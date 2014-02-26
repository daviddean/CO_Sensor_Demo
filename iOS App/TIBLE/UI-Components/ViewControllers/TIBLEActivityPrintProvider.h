/*
 *  TIBLEActivityPrintProvider.h
 *  TI BLE Sensor App
 *  05/08/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

/* Only supports a NSString for now.*/

#import <UIKit/UIKit.h>

@interface TIBLEActivityPrintProvider : UIActivityItemProvider

- (id) initWithItemString:(NSString *) itemString;

@end
