/*
 *  TIBLERootViewController_iPad.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLERootViewController_iPad.h"
#import "KSCustomPopoverBackgroundView.h"
#import "TIBLESensorInfoViewController.h"
#import "TIBLEGraphViewController.h"
#import "TIBLEConnectViewController.h"
#import "TIBLESettingsViewController.h"
#import "TIBLEInfoViewController.h"
#import "TIBLEMainScreenViewController_iPad.h"
#import "TIBLEUIConstants.h"
#import "TIBLEDeviceListPickerManager.h"
#import "TIBLEDevicesManager.h"
#import "TIBLEResourceConstants.h"
#import "TIBLEFeatures.h"
#import "TIBLEUIConstants.h"

@interface TIBLERootViewController_iPad ()<UIPopoverControllerDelegate,
TIBLEDevicesListPickerManagerDelegate,
MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UIPopoverController * popVC;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem * settingsBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *connectBarButtonItem;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIView *mainScreenView;

@property (nonatomic, strong) TIBLEDeviceListPickerManager * devicePickerManager;
@property (nonatomic, strong) TIBLEMainScreenViewController_iPad * mainScreenVC;

@property (nonatomic, assign) UIInterfaceOrientation lastLayoutOrientation;
@property (nonatomic, assign) BOOL devicePickerShowing;

@property (nonatomic, strong) UIActivityViewController * activityViewController;

@end

@implementation TIBLERootViewController_iPad


#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	
    if (self) {
		
		self.devicePickerManager = [[TIBLEDeviceListPickerManager alloc] init];
		self.devicePickerManager.delegate = self;
		
    }
    return self;
}

#pragma mark - View Loading

- (void) viewDidLoad
{
	[TIBLELogger detail:@"TIBLERootViewController_iPad - View Did Load called.\n"];
	
    [super viewDidLoad];
	
	[self resizeViewForCurrentOrientation];

	[self buildMainVC];
	
	//just for fun, listen to see what is going on!
	[self registerForDeviceOrientationNotifications];
	
	[self registerForNotifications];
	
	self.connectBarButtonItem.enabled = YES;
	self.infoBarButtonItem.enabled = YES;
	
	self.settingsBarButtonItem.enabled = NO;
	self.shareBarButtonItem.enabled = NO;
	
	[self removeShareButtonIfNotSupported];
}

- (void) removeShareButtonIfNotSupported{
	
	NSString *OSVersion = [[UIDevice currentDevice] systemVersion];
    
    if (self.shareBarButtonItem != nil && [OSVersion hasPrefix:@"5."]) {
		
		self.shareBarButtonItem.enabled = NO;
        self.shareBarButtonItem = nil;
    }
}

- (void) resizeViewForCurrentOrientation{
	//since iOS will load view in portrait even though when in landscape,
	//need to resize view correctly for orientation.
	CGRect screenSize = [[UIScreen mainScreen] bounds];
	
	float min = MIN(self.view.bounds.size.height, self.view.bounds.size.width);
	float max = MAX(self.view.bounds.size.height, self.view.bounds.size.width);
	
	if(screenSize.size.width > screenSize.size.height){
		//[TIBLELogger detail:@"*** width is greater than height."];
	}
	else{
		//[TIBLELogger detail:@"*** height is greater than width"];
	}
	
	//UIDeviceOrientation orientation = [UIDevice currentDevice].≈; //does not work sometimes.
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	
    if (UIDeviceOrientationIsPortrait(orientation)) {
		//[TIBLELogger detail:@"*** Orientation is: Portrait"];
		self.view.frame = CGRectMake(0.0f, 0.0f, min, max);
    }
    else {
		//[TIBLELogger detail:@"*** Orientation is: Landscape"];
		self.view.frame = CGRectMake(0.0f, 0.0f, max, min);
    }	
}

- (void)viewDidUnload {
	
	[self setShareBarButtonItem:nil];
	[self setInfoBarButtonItem:nil];
	[self setConnectBarButtonItem:nil];
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Handle Orientation (subsequent after launch)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	[TIBLELogger detail:@"TIBLERootViewController_iPad - ShouldAutorotateToInterfaceOrientation called."];
	//say yes to all orientations.
    return YES;
}

//called first
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	
	[TIBLELogger detail:@"TIBLERootViewController_iPad - WillRotateFromInterfaceOrientation called."];
	
	//do nothing so far.
	
}

//called second
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	
	[TIBLELogger detail:@"TIBLERootViewController_iPad - willAnimateRotationToInterfaceOrientation called."];
	[self rotate];
}


//called third
/*after the launching, this method is called. For the launch in landscape, we resize the view in
 * viewDidLoad. */
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	
	[TIBLELogger detail:@"TIBLERootViewController_iPad - DidRotateFromInterfaceOrientation called."];
}

- (void) viewWillAppear:(BOOL)animated{
	
	[self rotate];
}

- (void) viewDidAppear:(BOOL)animated{
	
	//nothing.
}

//called third
- (void) rotate{
	
	[TIBLELogger detail:@"TIBLERootViewController_iPad - *** Rotate called."];
	
	UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
	
	if(self.lastLayoutOrientation != currentOrientation){
	
		[self buildMainVC];
	}
}

- (void) buildMainVC{
	
	[self.mainScreenVC removeFromParentViewController];
	[self.mainScreenVC.view removeFromSuperview];
	
	self.mainScreenVC = [[TIBLEMainScreenViewController_iPad alloc] initWithNibName:nil bundle:nil];
	
	[self addChildViewController:self.mainScreenVC];
	self.mainScreenVC.view.frame = self.mainScreenView.bounds;
	[self.mainScreenView addSubview:self.mainScreenVC.view];
	
	self.lastLayoutOrientation = [UIApplication sharedApplication].statusBarOrientation;
}

#pragma mark - Listen for Orientation Change (for fun)

- (void)changeOrientation {
	
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	
    if (UIDeviceOrientationIsPortrait(orientation)) {
		[TIBLELogger detail:@"TIBLERootViewController_iPad - Changing Orientation to: Portrait"];
    }
    else {
		[TIBLELogger detail:@"TIBLERootViewController_iPad - Changing Orientation to: Landscape"];
	}
}

- (void) registerForDeviceOrientationNotifications{
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - UI Debug Utility Methods

- (void) printViewFrame:(UIView *) uiview{

	[TIBLELogger detail:@"\t frame: x:%f y:%f w:%f h:%f",
		  uiview.frame.origin.x,
		  uiview.frame.origin.y,
		  uiview.frame.size.width,
		  uiview.frame.size.height];
}

- (void) printViewBounds:(UIView *) uiview{
	
	[TIBLELogger detail:@"\t bounds: x:%f y:%f w:%f h:%f",
		  uiview.bounds.origin.x,
		  uiview.bounds.origin.y,
		  uiview.bounds.size.width,
		  uiview.bounds.size.height];
}

#pragma mark - Settings Hide / Show

- (void) showSettings{
	
	NSMutableArray * toolbarButtonItems = [NSMutableArray arrayWithArray:
											 [self.toolbar items]];
	
	bool found = NO;
	
	for(UIBarButtonItem * tmpButton in toolbarButtonItems){
		
		if(tmpButton == self.settingsBarButtonItem){
			
			//keep it
			found = YES;
			break;
		}
	}
	
	if(found == NO){
		
		[toolbarButtonItems insertObject:self.settingsBarButtonItem atIndex:1]; //insert item at index you like.
		
		[self.toolbar setItems:toolbarButtonItems];
	}
	
	[self updateConnectedSensorButtons:nil];
}

- (void) hideSettings{
	
	
	NSMutableArray * toolbarButtonItems = [NSMutableArray arrayWithArray:
										   [self.toolbar items]];
	
	bool found = NO;
	
	for(UIBarButtonItem * tmpButton in toolbarButtonItems){
		
		if(tmpButton == self.settingsBarButtonItem){
			
			found = YES;
					
			[toolbarButtonItems removeObject:tmpButton];
			
			break;
		}
	}
	
	if(found == YES){
		
		[self.toolbar setItems:toolbarButtonItems];
	}
	
	[self updateConnectedSensorButtons:nil];
}

#pragma mark - Toolbar Actions

- (IBAction)showSettings:(id)sender {

	[self dismissPopovers];
	
	TIBLESettingsViewController * settingsVC = [[TIBLESettingsViewController alloc] init];
	
	if(settingsVC == nil)
		return;
	
	UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
	navController.title = NSLocalizedString(@"Settings.title", nil);
	navController.accessibilityLabel = TIBLE_UI_COMPONENT_SETTINGS_VC_IDENTIFIER;
	
	if(navController == nil)
		return;
	
	self.popVC = [[UIPopoverController alloc] initWithContentViewController:navController];
	self.popVC.popoverBackgroundViewClass = [KSCustomPopoverBackgroundView class];
	self.popVC.delegate = self;
	[self.popVC presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)showConnect:(id)sender {

	[self dismissPopovers];
	
	TIBLEConnectViewController * connectVC = [[TIBLEConnectViewController alloc] init];
	
	if(connectVC == nil)
		return;
	
	UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:connectVC];
	navController.title = NSLocalizedString(@"Connect.title", nil);;
	navController.accessibilityLabel = TIBLE_UI_COMPONENT_CONNECT_VC_IDENTIFIER;
	
	if(navController == nil)
		return;

	self.popVC = [[UIPopoverController alloc] initWithContentViewController:navController];
	
	self.popVC.popoverBackgroundViewClass = [KSCustomPopoverBackgroundView class];
	self.popVC.delegate = self;
	[self.popVC presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)showShare:(id)sender {
	
	[self dismissPopovers];
	
	if(self.mainScreenVC.graphVC == nil)
		return;
	
	float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	
	BOOL activityVCSupported = YES;
	
	if (osVersion < 6.0) {
		activityVCSupported = NO;
	}
	
	if(TIBLE_FEATURE_ENABLE_SHARE_ACTIVITY_VIEW_CONTROLLER && activityVCSupported){
		
		self.activityViewController = [self.mainScreenVC.graphVC sharedActivityControllerWithGraphData];

		self.activityViewController.title = NSLocalizedString(@"Share.title", nil);;
		self.activityViewController.accessibilityLabel = TIBLE_UI_COMPONENT_SHARE_VC_IDENTIFIER;
		
		__weak TIBLERootViewController_iPad * weakSelf = self;
		
		[self.activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
			
			weakSelf.activityViewController.excludedActivityTypes = nil;
			
			weakSelf.activityViewController = nil;
		}];
		
		if(self.activityViewController == nil){
			return;
		}
		
		self.popVC = [[UIPopoverController alloc] initWithContentViewController:self.activityViewController];
	}
	else{
		
		MFMailComposeViewController * emailComposerViewController = [self.mainScreenVC.graphVC sharedEmailControllerWithGraphData];
		
		if(emailComposerViewController == nil){
			return;
		}
		
		emailComposerViewController.mailComposeDelegate = self;
		emailComposerViewController.title = NSLocalizedString(@"Share.title", nil);
		emailComposerViewController.accessibilityLabel = TIBLE_UI_COMPONENT_SHARE_VC_IDENTIFIER;
		
		self.popVC = [[UIPopoverController alloc] initWithContentViewController:emailComposerViewController];
	}
	
	//put activity view controller inside a popover.
	self.popVC.popoverBackgroundViewClass = [KSCustomPopoverBackgroundView class];
	self.popVC.accessibilityLabel = TIBLE_UI_COMPONENT_SHARE_VC_IDENTIFIER;
	
	self.popVC.delegate = self;
	[self.popVC presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)infoButtonClicked:(id)sender {
    
    [self dismissPopovers];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
	
	[controller dismissModalViewControllerAnimated:YES];
	[self.popVC dismissPopoverAnimated:YES];
}

#pragma mark - Setters / Getters

- (TIBLESensorModel * ) sensor{
	
	return [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
}


- (void) setLastLayoutOrientation:(UIInterfaceOrientation)lastLayoutOrientation{
	
	if(_lastLayoutOrientation != lastLayoutOrientation){
		
		[TIBLELogger info:@"RootViewController_iPad: Setting last orientation layout to: %d\n", lastLayoutOrientation];
		
		_lastLayoutOrientation = lastLayoutOrientation;
	}
}

#pragma mark - Notification Registration

- (void) registerForNotifications{
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updadeDeviceListAlert:)
												 name:TIBLE_NOTIFICATION_UPDATE_DEVICE_LIST
											   object:nil];
	
	//yes, register for the same notification twice.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectedSensorChanged:)
												 name:TIBLE_NOTIFICATION_UPDATE_CONNECTED_SENSOR_CHANGED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateConnectedSensorButtons:)
												 name:TIBLE_NOTIFICATION_BLE_RECEIVING_SAMPLES
											   object:nil];
	
}

- (void) unregisterForNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Callbacks

- (void) updateConnectedSensorButtons: (NSNotification *) notif{

	if(self.sensor != nil &&
	   [self.sensor.sensorSamples containsSamples]){
	
		self.shareBarButtonItem.enabled = YES;
		self.settingsBarButtonItem.enabled = YES;
	}
	else{
		self.shareBarButtonItem.enabled = NO;
		self.settingsBarButtonItem.enabled = NO;
	}
	
	[self.toolbar setNeedsDisplay];
}

- (void) connectedSensorChanged: (NSNotification *) notif{
	
	[self updateConnectedSensorButtons:nil];
	[self showDeviceListAlert];
}

- (void) updadeDeviceListAlert: (NSNotification *) notif{
	
	[self showDeviceListAlert];
}

#pragma mark - Device Picker

- (BOOL) showDeviceListAlert{
	
	BOOL didShow = NO;
	
	//if connect popover showing, then let it be.
	if([self isConnectPopoverShowing] == YES) {
		return didShow;
	}
	
	//if other popovers are showing, dismiss them.
	if([self isPopoverShowing] == YES){
		[self dismissPopovers];
	}
	
	//only show if not showing connect popover and connected sensor becomes nil.
	
	if([[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor] == nil){
		//then show the picker. if already showing does nothing.
		[self.devicePickerManager showDevicesListAlert];
	}
	
	didShow = YES;
	
	return didShow;
}

#pragma mark - Popovers

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
	
	self.popVC = nil;
}

- (void) dismissPopovers{
	
    [self.popVC dismissPopoverAnimated:YES];
    self.popVC = nil;
}

- (BOOL) isPopoverShowing{
	
	BOOL retVal = NO;
	
	if(self.popVC != nil){
		
		retVal = YES;
    }
	
	return retVal;
}

- (BOOL) isConnectPopoverShowing{
	
	BOOL retVal = NO;
	UIViewController * contentVC = self.popVC.contentViewController;
	
	if((contentVC != nil) &&
	   [contentVC.accessibilityLabel isEqualToString:TIBLE_UI_COMPONENT_CONNECT_VC_IDENTIFIER] &&
	   self.popVC.isPopoverVisible){
		
		retVal = YES;
    }
	
	return retVal;
}


#pragma mark - Toolbar Enable/Disable Buttons

- (void) devicePickerDidHide{
	
	self.devicePickerShowing = NO;

	self.connectBarButtonItem.enabled = YES;
	self.infoBarButtonItem.enabled = YES;

	[self updateConnectedSensorButtons:nil];
}

- (void) devicePickerDidShow{
	
	self.devicePickerShowing = YES;

	self.connectBarButtonItem.enabled = NO;
	self.infoBarButtonItem.enabled = NO;
	self.settingsBarButtonItem.enabled = NO;
	self.shareBarButtonItem.enabled = NO;
	
	[self.toolbar setNeedsDisplay];
}


@end
