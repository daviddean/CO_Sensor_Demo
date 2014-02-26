/*
 *  TIBLEActivityMailProvider.h
 *  TI BLE Sensor App
 *  05/08/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <UIKit/UIKit.h>

/* The itemURL is returned as a file attachment. */

@interface TIBLEActivityMailProvider : UIActivityItemProvider

- (id) initWithAttachmentURL:(NSURL *) itemURL;

@end
