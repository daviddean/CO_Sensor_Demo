/*
 *  TIBLEActivityClipboardProvider.h
 *  TI BLE Sensor App
 *  05/08/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <UIKit/UIKit.h>

/* Puts a NSString with contents of URL or itemString in clipboard. */

@interface TIBLEActivityClipboardProvider : UIActivityItemProvider

- (id) initWithItemString:(NSString *) itemString;
- (id) initWithItemURL:(NSURL *) itemURL;

@end
