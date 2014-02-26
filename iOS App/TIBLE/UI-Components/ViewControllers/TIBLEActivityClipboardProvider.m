/*
 *  TIBLEActivityClipboardProvider.m
 *  TI BLE Sensor App
 *  05/08/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEActivityClipboardProvider.h"


@interface TIBLEActivityClipboardProvider ()

@property (nonatomic, strong) NSString * stringData;

@end

@implementation TIBLEActivityClipboardProvider

- (id) initWithItemString:(NSString *) itemString{
	
	self = [super init];
	
	if(self != nil){
	
		self.stringData = itemString;
	}
	
	return self;
}

- (id) initWithItemURL:(NSURL *) itemURL{
	
	self = [super init];
	
	if(self != nil){
		
		NSString * stringData = [NSString stringWithContentsOfURL:itemURL
														 encoding:NSUTF8StringEncoding error:nil];
		
		self.stringData = stringData;
	}
	
	return self;
}

// called to fetch data
- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
	id data = nil;
	
	if([activityType isEqualToString:UIActivityTypeCopyToPasteboard]){
		data = self.stringData;
	}
	
	return data;
}

// called to determine data type
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
	
	return self.stringData;
}

// called by -main when data is needed. default returns nil. Subclass to override and call status/progress. called on secondary thread
//- (id)item{
//
//}


@end
