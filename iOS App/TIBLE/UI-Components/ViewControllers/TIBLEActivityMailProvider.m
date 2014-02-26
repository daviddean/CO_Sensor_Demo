/*
 *  TIBLEActivityMailProvider.m
 *  TI BLE Sensor App
 *  05/08/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEActivityMailProvider.h"

@interface TIBLEActivityMailProvider ()

@property (nonatomic, strong) NSURL * urlData;

@end

@implementation TIBLEActivityMailProvider

- (id) initWithAttachmentURL:(NSURL *) itemURL{
	
	self = [super init];
	
	if(self != nil){
		
		self.urlData = itemURL;
	}
	
	return self;
}

// called to fetch data
- (id) activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
	id data = nil;
	
	if([activityType isEqualToString:UIActivityTypeMail]){
		data = self.urlData;
	}
	
	return data;
}

// called to determine data type
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
	
	return self.urlData;
}

// called by -main when data is needed. default returns nil. Subclass to override and call status/progress. called on secondary thread
//- (id)item{
//
//}

@end
