/*
 *  TIBLELogger.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>

#define TIBLE_LOG_LEVEL TIBLELogLevelError

typedef enum
{
	TIBLELogLevelNone,
	TIBLELogLevelCrash,
	TIBLELogLevelError,
	TIBLELogLevelWarning,
	TIBLELogLevelInfo,
	TIBLELogLevelDetail,
    TIBLELogLevelAll
}

TIBLELogLevel;

@interface TIBLELogger : NSObject

+ (void)crash:(NSString *)format, ...;
+ (void)error:(NSString *)format, ...;
+ (void)warn:(NSString *)format, ...;
+ (void)info:(NSString *)format, ...;
+ (void)detail:(NSString *)format, ...;
+ (void)log:(NSString *)format, ...;

@end
