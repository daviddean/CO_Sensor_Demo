/*
 *  TIBLEAliasViewController.h
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

/**
* This class is used to display the appropriate web page for each
* TI product that is displayed in the Info tab of the App.
*/

#import <UIKit/UIKit.h>

@interface TIBLEAliasViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *aliasWebView; /*!< Reference to the currently displayed view. */
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator; /*!< Shown when aliasWebView is loading. */
@property (weak, nonatomic) IBOutlet UILabel *noConnectionLabel; /*!< Informs the user that there is no internet connection available. */

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

/**
* Tells the instance to load a web page
* @param url The url of the page that we wish to load
* @param title The title to display in the navigation bar
*/
- (void)loadPageWithURL:(NSString *)url pageTitle:(NSString *)title;

@end
