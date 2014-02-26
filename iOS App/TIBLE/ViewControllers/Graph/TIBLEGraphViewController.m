/*
 *  TIBLEGraphViewController.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEGraphViewController.h"
#import "TIBLEScatterPlotViewController.h"
#import "TIBLEScatterPlotViewController+DataSource.h"
#import "TIBLEScatterPlotViewController+Export.h"
#import "TIBLEHeaderView.h"
#import "TIBLEUIConstants.h"
#import "TIBLENoSensorAvailableViewController.h"
#import "TIBLEDevicesManager.h"
#import "TIBLEStretchableImageView.h"
#import "TIBLEFeatures.h"
#import "TIBLESettingsManager.h"
#import "TIBLELoadingViewController.h"
#import "TIBLEUtilities.h"
#import "TIBLEResourceConstants.h"
#import "TIBLEActivityPrintProvider.h"
#import "TIBLEActivityClipboardProvider.h"
#import "TIBLEActivityMailProvider.h"

@interface TIBLEGraphViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton_iPhone;
@property (strong, nonatomic) IBOutlet TIBLEStretchableImageView *stretchableGraphTitleImageView;
@property (weak, nonatomic) IBOutlet TIBLEStretchableImageView *stretchableGraphBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (strong, nonatomic) IBOutlet TIBLEHeaderView *graphSubTitleHeaderView;
@property (strong, nonatomic) IBOutlet TIBLEHeaderView *graphTitleHeaderView;
@property (strong, nonatomic) IBOutlet UIView *graphContainerView;
@property (strong, nonatomic) IBOutlet UIView *graphParentContainerView;
@property (strong, nonatomic) IBOutlet UIButton *pauseResumeButton;
@property (weak, nonatomic) IBOutlet TIBLEStretchableImageView *stretchableGraphBackgroundPortraitImageView;
@property (strong, nonatomic) TIBLEScatterPlotViewController * scatterPlotVC;
@property (strong, nonatomic) TIBLENoSensorAvailableViewController * noSensorAvailableVC;
@property (nonatomic, strong) TIBLELoadingViewController * loadingVC;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL displayNoSensorAvailableUI;
@property (nonatomic, assign) BOOL displayLoadingUI;

@property (strong, nonatomic) UIActivityViewController * activityVC;

@end

static BOOL _isPaused = NO;

@implementation TIBLEGraphViewController

+ (BOOL)isPaused {
    return _isPaused;
}

#pragma mark - Init Routines

//called for iphone from storyboard
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        self.title = NSLocalizedString(@"Graph.title", @"Graph tab title");
        
		self.accessibilityLabel = TIBLE_UI_COMPONENT_GRAPH_VC_IDENTIFIER;
		self.navigationController.accessibilityLabel = TIBLE_UI_COMPONENT_GRAPH_VC_IDENTIFIER;
		
		self.displayNoSensorAvailableUI = TIBLE_FEATURE_ENABLE_NO_SENSOR_AVAILABLE_UI;
		self.isLoading = self.service.isReadingCharacteristics;
		self.displayLoadingUI = YES;
    }
	
    return self;
}

//called for ipad from init of main vc.
- (NSString*) nibNameRotated:(UIInterfaceOrientation)orientation
{
    if( UIInterfaceOrientationIsLandscape(orientation))
		return [NSString stringWithFormat:@"%@-landscape", NSStringFromClass([self class])];
	
    return [NSString stringWithFormat:@"%@", NSStringFromClass([self class])];
}

//called for ipad. ipad does not display loading and no sensor available vc.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if(nibNameOrNil == nil)
		nibNameOrNil = [self nibNameRotated:[[UIApplication sharedApplication] statusBarOrientation]];
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   
    if (self) {
        
		self.title = NSLocalizedString(@"Graph.title", @"Graph tab title");
		self.accessibilityLabel = TIBLE_UI_COMPONENT_GRAPH_VC_IDENTIFIER;
		self.navigationController.accessibilityLabel = TIBLE_UI_COMPONENT_GRAPH_VC_IDENTIFIER;
		
		BOOL isiPhone = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
		
		self.displayNoSensorAvailableUI = TIBLE_FEATURE_ENABLE_NO_SENSOR_AVAILABLE_UI && isiPhone;
		self.isLoading = self.service.isReadingCharacteristics;
		self.displayLoadingUI = isiPhone;
		
		self.noSensorAvailableVC = [[TIBLENoSensorAvailableViewController alloc] initWithNibName:@"TIBLENoSensorAvailableViewController" bundle:nil];
		self.loadingVC = [[TIBLELoadingViewController alloc] initWithNibName:@"TIBLELoadingViewController" bundle:nil];
    }
	
    return self;
}

- (void) customLoad{
	
	[self createScatterPlotVC];
	[self createNoSensorAvailableVC];
	[self createLoadingVC];
	[self configureHeaders];
	
	[self registerForNotifications];
	
	[self updateViews];
	[self updateGraph:nil];
	
	[self removeShareButtonIfNotSupported];
}

- (void) removeShareButtonIfNotSupported{
	
	NSString *OSVersion = [[UIDevice currentDevice] systemVersion];
    
    if (self.shareButton_iPhone != nil &&
		[OSVersion hasPrefix:@"5."]) {
		
		self.shareButton_iPhone.enabled = NO;
        self.shareButton_iPhone = nil;
    }
}

#pragma mark - Configure Headers

- (void) configureHeaders{
	
	if(self.sensor != nil){
		
		TIBLESensorProfile * sensorProfile = [[TIBLESettingsManager sharedTIBLESettingsManager] setting];
		
		[self setGraphSubTitle:sensorProfile.graph_subTitle];
		[self setGraphTitle:sensorProfile.graph_title];
	}
	else{
		[self setGraphSubTitle:NSLocalizedString(@"GraphScreen.Title.Placeholder", @"Title NA")];
		[self setGraphTitle:NSLocalizedString(@"GraphScreen.SubTitle.Placeholder", @"SubTitle NA")];
	}
}

#pragma mark - View Controller Routines

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self customLoad];
    
    [self setIsPaused:_isPaused];
}

-(void)viewDidAppear:(BOOL)animated {
	
    [super viewDidAppear:animated];
    
    [self resizeFrame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc{
	
	[self cleanup];
	[self unregisterForNotifications];
	
	self.stretchableGraphTitleImageView = nil;
	self.graphSubTitleHeaderView = nil;
	self.graphTitleHeaderView = nil;
	self.graphContainerView = nil;
	self.graphParentContainerView = nil;
	self.pauseResumeButton = nil;
	self.scatterPlotVC = nil;
	self.noSensorAvailableVC = nil;
	self.loadingVC = nil;
}

#pragma mark - Child View Controller Routines

- (void) createScatterPlotVC{
	
	//remove
	[self cleanScatterPlotVC];
	
	//create
	self.scatterPlotVC = [[TIBLEScatterPlotViewController alloc] init];
	
	//add
	[self.graphContainerView addSubview:self.scatterPlotVC.view];
	[self addChildViewController:self.scatterPlotVC];
	
	//set frame
	self.scatterPlotVC.view.frame = self.graphContainerView.bounds;
}

- (void) createNoSensorAvailableVC{
	
	//remove
	[self cleanNoSensorAvailableVC];
	
	//create
	self.noSensorAvailableVC = [[TIBLENoSensorAvailableViewController alloc]
								initWithNibName:@"TIBLENoSensorAvailableViewController" bundle:nil];
	
	//add
	[self addChildViewController:self.noSensorAvailableVC];
}

- (void) createLoadingVC{
	
	//remove
	[self cleanLoadingVC];
	
	//create
	self.loadingVC = [[TIBLELoadingViewController alloc]
					  initWithNibName:@"TIBLELoadingViewController" bundle:nil];
	
	//add
	[self addChildViewController:self.loadingVC];
}

#pragma mark - Getters

- (TIBLEService *) service{
	
	return [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedService];
}

- (TIBLESensorModel * ) sensor{
	
	return [[TIBLEDevicesManager sharedTIBLEDevicesManager] connectedSensor];
}

#pragma mark - Setters

- (void) setIsPaused:(BOOL)isPaused{

    _isPaused = isPaused;
    
    self.scatterPlotVC.isPaused = isPaused;
    
    if(isPaused){
        [self.pauseResumeButton setImage:[UIImage imageNamed:@"play_button.png"]
                                forState:UIControlStateNormal];
    }
    else{
        [self.pauseResumeButton setImage:[UIImage imageNamed:@"pause_button.png"]
                                forState:UIControlStateNormal];
    }
}

#pragma mark - Register / Unregister Notifications

- (void) unregisterForNotifications{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) registerForNotifications{
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateGraph:)
												 name:TIBLE_NOTIFICATION_UPDATE_CHARACTERISTC_VALUE_UPDATED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(rebuildGraph:)
												 name:TIBLE_NOTIFICATION_UPDATE_MEASUREMENT_SAMPLE_RECEIVED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectedSensorChanged:)
												 name:TIBLE_NOTIFICATION_UPDATE_CONNECTED_SENSOR_CHANGED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectedSensorStartedReadingCharacteristics:)
												 name:TIBLE_NOTIFICATION_BLE_CHARACTERISTICS_READING_STARTED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectedSensorEndedReadingCharacteristics:)
												 name:TIBLE_NOTIFICATION_BLE_CHARACTERISTICS_READING_ENDED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(connectedSensorIsReceivingSamples:)
												 name:TIBLE_NOTIFICATION_BLE_RECEIVING_SAMPLES
											   object:nil];
}


#pragma mark - Notification Callbacks

- (void) updateGraph: (NSNotification *) notif{
    
    [self setIsPaused:NO];
	
	[self configureHeaders];
}

- (void) connectedSensorStartedReadingCharacteristics: (NSNotification *) notif{
	
	//do nothing.
}

- (void) connectedSensorEndedReadingCharacteristics: (NSNotification *) notif{
	//do nothing.
}

- (void) connectedSensorIsReceivingSamples: (NSNotification *) notif{
	
	self.isLoading = NO;
	
	[self updateViews];
}

- (void) rebuildGraph: (NSNotification *) notif{
	
	//used in scatter plot VC.
}

- (void) connectedSensorChanged: (NSNotification *) notif{
	
	[TIBLELogger info:@"TIBLEGraphViewController - Connected Sensor Changed called."];
	
	self.isLoading = YES;
	
	if(self.sensor != nil){
		
		//if sensor has changed, or even connection is new,
		//reload controller.
		
		[self createScatterPlotVC];
		[self createNoSensorAvailableVC];
		[self createLoadingVC];
		
		[self updateViews];
		[self updateGraph:nil];
	}
	else{
		
		//if sensor is empty,
		[self createScatterPlotVC];
		[self createNoSensorAvailableVC];
		[self createLoadingVC];
		
		[self updateViews];
		[self updateGraph:nil];
	}
    
    [self setIsPaused:NO];
}

#pragma mark - Actions

- (IBAction)pauseResumeButtonTapped:(id)sender {

	[self setIsPaused:!_isPaused];
}

- (IBAction)shareActionTapped:(id)sender {
	
	float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	
	BOOL activityVCSupported = YES;
	
	if (osVersion < 6.0) {
		activityVCSupported = NO;
	}
	
	if(TIBLE_FEATURE_ENABLE_SHARE_ACTIVITY_VIEW_CONTROLLER && activityVCSupported){
		
		self.activityVC = [self sharedActivityControllerWithGraphData];
		
		__weak TIBLEGraphViewController * weakSelf = self;
		
		[self.activityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
			
			weakSelf.activityVC.excludedActivityTypes = nil;
			
			weakSelf.activityVC = nil;
		}];
		
		[self presentViewController:self.activityVC animated:YES completion:^{}];
	}
	else{
		
		MFMailComposeViewController * emailComposerViewController = [self sharedEmailControllerWithGraphData];
		emailComposerViewController.mailComposeDelegate = self;
		
		[self presentViewController:emailComposerViewController animated:YES completion:^{}];
	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
	
	[controller dismissModalViewControllerAnimated:YES];
}

- (UIActivityViewController *) sharedActivityControllerWithGraphData{
	
	//pause so we can capture the right annotation at the moment
	//in time the user tapped to export.
	//user has to press play to resume.
	[self setIsPaused:YES];
	
	NSString * messageBody = [self sharedMessageBody];
	NSURL * pdfDataURL = [self.scatterPlotVC pdfGraphDataURL];
	NSURL * csvDataURL = [self.scatterPlotVC csvGraphDataURL];
	NSString * csvDataString = [self.scatterPlotVC csvGraphString];

	TIBLEActivityPrintProvider * activityPrintProvider = [[TIBLEActivityPrintProvider alloc] initWithItemString:[messageBody stringByAppendingString:csvDataString]];
	TIBLEActivityClipboardProvider * activityClipboardProvider = [[TIBLEActivityClipboardProvider alloc] initWithItemString:csvDataString];
	TIBLEActivityMailProvider * activityMailProviderPDF = [[TIBLEActivityMailProvider alloc] initWithAttachmentURL:pdfDataURL];
	TIBLEActivityMailProvider * activityMailProviderCSV = [[TIBLEActivityMailProvider alloc] initWithAttachmentURL:csvDataURL];
	
	NSArray * activityItems = @[messageBody, activityPrintProvider, activityClipboardProvider, activityMailProviderPDF, activityMailProviderCSV];

	UIActivityViewController * activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems
																			  applicationActivities:nil];

	//exclude all activity types other than UIActivityTypeMail, UIActivityTypePrint, and UIActivityTypeCopyToPasteboard.
	
	NSArray * array = [NSArray arrayWithObjects:UIActivityTypePostToFacebook,
					   										UIActivityTypePostToTwitter,
					   										UIActivityTypePostToWeibo,
					   										UIActivityTypeMessage,
					   										UIActivityTypeAssignToContact,
					   										UIActivityTypeSaveToCameraRoll,
					   										nil];
		
	activityVC.excludedActivityTypes = array;

	
	[activityVC setCompletionHandler:^(NSString *act, BOOL done)
	 {
		 NSString * alertTitle = @"";
		 NSString * alertBody = NSLocalizedString(@"Sharing.Done.Message", nil);
		 NSString * alertButton = NSLocalizedString(@"Alert.OK", nil);
		 
		 if([act isEqualToString:UIActivityTypeMail]){
			 alertTitle = NSLocalizedString(@"Sharing.EmailSent.Message", nil);
		 }
		 else if ([act isEqualToString:UIActivityTypeCopyToPasteboard]){
			 alertTitle = NSLocalizedString(@"Sharing.CopyToClipboard.Message", nil);
		 }
		 else if ([act isEqualToString:UIActivityTypePrint]){
			 alertTitle = NSLocalizedString(@"Sharing.Print.Message", nil);
		 }
		 		 
		 if(done == YES)
		 {
			 UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:alertTitle
															 message:alertBody
															delegate:nil
												   cancelButtonTitle:alertButton
												   otherButtonTitles:nil];
			 [alertView show];
		 }
	 }];

	return activityVC;
}

- (MFMailComposeViewController *) sharedEmailControllerWithGraphData{

	MFMailComposeViewController * emailComposer = nil;
	
	if ([MFMailComposeViewController canSendMail]) {
		
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
		
		//set subject
		NSString * emailSubject = NSLocalizedString(@"Email.Subject", @"Email Subject");
		[mailViewController setSubject:emailSubject];
		
		//set message
		NSString * messageBody = [self sharedMessageBody];
		[mailViewController setMessageBody:messageBody isHTML:NO];
		
		//get attachment data
		NSURL * pdfData = [self.scatterPlotVC pdfGraphDataURL];
		NSURL * csvData = [self.scatterPlotVC csvGraphDataURL];
		
		//add attachments (csv, and pdf)
		[mailViewController addAttachmentData:[NSData dataWithContentsOfURL:pdfData]  mimeType:MIME_TYPE_PDF fileName:[pdfData lastPathComponent]];
		[mailViewController addAttachmentData:[NSData dataWithContentsOfURL:csvData] mimeType:MIME_TYPE_CSV fileName:[csvData lastPathComponent]];
		
		emailComposer = mailViewController;
	}
	else {
		[TIBLELogger warn:@"TIBLEGraphViewController - Warning. Device is unable to send email in its current state."];
	}
	
	return emailComposer;
}

- (NSString *) sharedMessageBody{
	
	NSString * messageBody = @"";
	
	//get sensor info if sensor is connected
	if(self.sensor != nil){
		
		NSString * sensorName = [self.sensor.peripheral nameStr];
		NSString * sensorType = [self.sensor.sensorProfile shortCaption];
		messageBody = [messageBody stringByAppendingFormat:@"%@ %@\n",
					   NSLocalizedString(@"Email.SensorName.Label", @"Sensor Name"),
					   sensorName];
		messageBody = [messageBody stringByAppendingFormat:@"%@ %@\n",
					   NSLocalizedString(@"Email.SensorType.Label", @"Sensor Type"),
					   sensorType];
	}
	
	//add a timestamp of when data was taken
	NSString * dateTimeStamp = [TIBLEUtilities dateAndTimeStampString];
	messageBody = [messageBody stringByAppendingFormat:@"%@\n\n", dateTimeStamp];
	
	return messageBody;
}

#pragma mark - Update UI Routines

- (void) updateViews{
	
	
	if(self.isViewLoaded == NO){
		
		[TIBLELogger detail:@"TIBLEGraphViewController - Not updating views since view is not loaded."];
	}
	else if(self.sensor != nil){
		
		if(self.isLoading && self.displayLoadingUI){
			
			[self displayLoadingView];
		}
		else{
			[self displaySensorAvailableViews];
		}
	}
	else { //sensor = nil
		
		if(self.displayNoSensorAvailableUI){
			
			[self displaySensorNotAvailableViews];
		}
		else{
			[self displaySensorAvailableViews];
		}
	}
	
	[self.view setNeedsLayout];
	[self.view setNeedsDisplay];
}

- (void) setGraphTitle:(NSString *) title{

	//for ipad
	[self.graphTitleHeaderView setTitleString:title];
	[self.graphTitleHeaderView.titleLabel setTextAlignment:NSTextAlignmentLeft];
	[self.graphTitleHeaderView.titleLabel setFont:[UIFont fontWithName:TIBLE_APP_FONT_NAME
																  size:TIBLE_APP_FONT_H1_HEADER_SIZE]];
	[self.graphTitleHeaderView.titleLabel setTextColor:[UIColor whiteColor]];
	
	[self.stretchableGraphTitleImageView setImageForName:@"background_graph_title_portrait.png"
											   andInsets:UIEdgeInsetsMake(30, 35, 30, 80)];

    //iPad landscape mode graph background
	[self.stretchableGraphBackgroundImageView setImageForName:@"background_graph_landscape.png"
													andInsets:UIEdgeInsetsMake(42, 42, 42, 42)];

    //iPad portrait mode graph background
    [self.stretchableGraphBackgroundPortraitImageView setImageForName:@"background_graph_portrait.png"
                                                    andInsets:UIEdgeInsetsMake(42, 42, 42, 42)];
	//for iphone
	self.titleBarButtonItem.title = title;
	
	[self.view setNeedsDisplay];
}

- (void) setGraphSubTitle:(NSString *) subTitle{
	
	[self.graphSubTitleHeaderView setTitleString:subTitle];
	[self.graphSubTitleHeaderView.titleLabel setTextColor:[UIColor whiteColor]];
	
	if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
		[self.graphSubTitleHeaderView.titleLabel setTextAlignment:NSTextAlignmentLeft];
		[self.graphSubTitleHeaderView.titleLabel setFont:[UIFont fontWithName:TIBLE_APP_FONT_NAME
																		 size:TIBLE_APP_FONT_H2_HEADER_SIZE]];
	}
	else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
		[self.graphSubTitleHeaderView.titleLabel setTextAlignment:NSTextAlignmentCenter];
		[self.graphSubTitleHeaderView.titleLabel setFont:[UIFont fontWithName:TIBLE_APP_FONT_NAME
																		 size:TIBLE_APP_FONT_H3_HEADER_SIZE]];
	}
	
	[self.view setNeedsDisplay];
}

- (void) displaySensorAvailableViews{
	
	//remove
	if([self.noSensorAvailableVC.view isDescendantOfView:self.view] == YES){
		[self.noSensorAvailableVC.view removeFromSuperview];
	}
	
	if([self.loadingVC.view isDescendantOfView:self.view] == YES){
		[self.loadingVC.view removeFromSuperview];
	}
	
	//add
	if([self.graphParentContainerView isDescendantOfView:self.view] == NO){
		[self.view addSubview:self.graphParentContainerView];
	}
	
	//resize
	self.scatterPlotVC.view.frame = self.graphContainerView.bounds;
}

- (void) displaySensorNotAvailableViews{
	
	//remove
	if([self.graphParentContainerView isDescendantOfView:self.view] == YES){
		[self.graphParentContainerView removeFromSuperview];
	}
	
	if([self.loadingVC.view isDescendantOfView:self.view] == YES){
		[self.loadingVC.view removeFromSuperview];
	}
	
	//add
	if([self.noSensorAvailableVC.view isDescendantOfView:self.view] == NO){
		[self.view addSubview:self.noSensorAvailableVC.view];
	}

	//resize
	self.noSensorAvailableVC.view.frame = CGRectMake(0.0f,
													 0.0f,
													 self.view.bounds.size.width,
													self.view.bounds.size.height);
}

- (void) displayLoadingView{
	
	//remove
	if([self.graphParentContainerView isDescendantOfView:self.view] == YES){
		[self.graphParentContainerView removeFromSuperview];
	}
	
	if([self.noSensorAvailableVC.view isDescendantOfView:self.view] == YES){
		[self.noSensorAvailableVC.view removeFromSuperview];
	}
	
	//add
	if([self.loadingVC.view isDescendantOfView:self.view] == NO){
		[self.view addSubview:self.loadingVC.view];
	}
	
	//resize
	self.loadingVC.view.frame = CGRectMake(0.0f,
										   0.0f,
										   self.view.bounds.size.width,
										   self.view.bounds.size.height);
}

#pragma mark - Clean Routines

- (void) cleanup{
	
	[self cleanScatterPlotVC];
	[self cleanNoSensorAvailableVC];
	[self cleanLoadingVC];
}

-(void) cleanNoSensorAvailableVC{
	
	//remove
	[self.noSensorAvailableVC.view removeFromSuperview];
	[self.noSensorAvailableVC removeFromParentViewController];
	
	//clean up
	self.noSensorAvailableVC = nil; //set to nil.
}

-(void) cleanScatterPlotVC{
	
	//remove
	[self.scatterPlotVC.view removeFromSuperview];
	[self.scatterPlotVC removeFromParentViewController];
	
	//clean up
	[self.scatterPlotVC cleanup];
	self.scatterPlotVC = nil; //set to nil.
}

-(void) cleanLoadingVC{
	
	//remove
	[self.loadingVC.view removeFromSuperview];
	[self.loadingVC removeFromParentViewController];
	
	//clean up
	self.loadingVC = nil; //set to nil.
}

- (void) resizeFrame {
    
    CGPoint graphEndPoint = CGPointMake(self.graphContainerView.frame.origin.x,
                                        self.graphContainerView.frame.origin.y + self.graphContainerView.frame.size.height);
    CGRect tabBarRect = self.tabBarController.tabBar.frame;
    
    if (CGRectContainsPoint(tabBarRect, graphEndPoint)) {
        CGRect temp = self.graphContainerView.frame;
        temp.size.height -= tabBarRect.size.height;
        self.graphContainerView.frame = temp;
    }
}

- (void)viewDidUnload {
	[self setShareButton_iPhone:nil];
	[super viewDidUnload];
}
@end
