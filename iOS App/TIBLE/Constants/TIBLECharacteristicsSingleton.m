/*
 *  TIBLECharacteristicsSingleton.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLECharacteristicsSingleton.h"
#import "TIBLESensorConstants.h"
#import "CBUUID+StringExtraction.h"
#import "TIBLEResourceConstants.h"

@implementation TIBLECharacteristicsSingleton

SINGLETON_FOR_CLASS(TIBLECharacteristicsSingleton)

-(id) init{
    self = [super init];
    
    if(self != nil){
        NSString *bundlePathofPlist = [[NSBundle mainBundle]pathForResource:kSensorProfileConstantsPlistFileName
																	 ofType:kFileExtensionPlist];
        self.dictionaryUUIDStrings = [NSDictionary dictionaryWithContentsOfFile:bundlePathofPlist];
    }
    return self;
}

- (NSArray *) generateCharacteristicsUUIDsArray{
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    NSArray * UUIDStrings = [self.dictionaryUUIDStrings allKeys];
    
    for(NSString * tempUUIDStr in UUIDStrings){
        [array addObject:[CBUUID UUIDWithString:tempUUIDStr]];
    }
    
    return array;
}

- (NSString *) characteristicDescriptionNameFromUUID:(CBUUID *) uuid{
	
	NSString * key = [uuid representativeString];
	
	return [self.dictionaryUUIDStrings objectForKey:[key uppercaseString]];
}


- (NSString *) characteristicKeyStringFromDescriptionName:(NSString *) descriptionName{
	
	NSArray * array = [self.dictionaryUUIDStrings allKeysForObject:descriptionName];
	
	NSString * retVal = nil;
	int count = [array count];
	
	if(count > 1){
		
		[TIBLELogger warn:@"TIBLECharacteristicsSingleton - Warning - More than one key string found for characteristic with description: %@\n", descriptionName];
	}
	
	if([array count] > 0){
		retVal = [array objectAtIndex:0];
	}
	
	return retVal;
}

@end
