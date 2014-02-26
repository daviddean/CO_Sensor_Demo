/*
 *  TIBLESettingsManager.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import <Foundation/Foundation.h>
@class TIBLESensorProfile;

/**
 * This singleton class is responsible for maintaining all user created settings
 * and for selecting the appropriate setting to use throughout the App.
 */

@interface TIBLESettingsManager : NSObject {
    NSMutableArray *allSettings; /*!< Contains all saved settings */
}

@property (strong, nonatomic) TIBLESensorProfile *setting; /*!< The setting that is used throughout the App. */

+ (TIBLESettingsManager *) sharedTIBLESettingsManager;

- (NSMutableArray *)allSettings; 

- (void)createSetting;

- (NSString *)settingsArchivePath;

- (BOOL)saveSettings;

- (void)removeSetting:(TIBLESensorProfile *)setting;

- (void)setSeletedSettingIndex:(int)index; 

- (void)setSetting; /*!< Sets the appropriate setting for the App. This method is triggered by certain user interactions. */

@end
