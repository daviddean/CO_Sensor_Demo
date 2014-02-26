/*
 *  TIBLEActivityPrintProvider.m
 *  TI BLE Sensor App
 *  05/08/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEActivityPrintProvider.h"

@interface TIBLEActivityPrintProvider ()

@property (nonatomic, strong) UISimpleTextPrintFormatter * printData;

@end

@implementation TIBLEActivityPrintProvider

- (id) initWithItemString:(NSString *) itemString{

	self = [super init];
	
	if(self != nil){

		if(itemString != nil){
			
			self.printData = [[UISimpleTextPrintFormatter alloc]
							  initWithText:itemString];
		}
	}
	return self;
}

- (id) initWithItemURL:(NSURL *) itemURL{

	self = [super init];
	
	if(self != nil){
		
		NSString * stringData = [NSString stringWithContentsOfURL:itemURL
														 encoding:NSUTF8StringEncoding error:nil];

		self.printData = [[UISimpleTextPrintFormatter alloc]
												 initWithText:stringData];
	}
	
	return self;
}

// called to fetch data
- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
	id data = nil;
	
	if([activityType isEqualToString:UIActivityTypePrint]){
		data = self.printData;
	}
	
	return data;
}

// called to determine data type
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
	
	return self.printData;
}

// called by -main when data is needed. default returns nil. Subclass to override and call status/progress. called on secondary thread
//- (id)item{
//	
//}

@end