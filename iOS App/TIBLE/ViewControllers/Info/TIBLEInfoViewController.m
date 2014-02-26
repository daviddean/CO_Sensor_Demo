/*
 *  TIBLEInfoViewController.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEInfoViewController.h"
#import "TIBLEAliasViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <QuickLook/QuickLook.h>
#import "TIBLEUIConstants.h"
#import "TIBLEURLConstants.h"
#import "TIBLEResourceConstants.h"

@interface TIBLEInfoViewController () <UIScrollViewDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate> {
    CGRect rect;
}

@property (strong, nonatomic) UIScrollView *scrollView; /*!< Enables the view to zoom. */
@property (weak, nonatomic) IBOutlet UITextView *copyrightTextView;
@property (weak, nonatomic) IBOutlet UITextView *aboutTextView;

@end

@implementation TIBLEInfoViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	
    if (self) {
		
		self.title = NSLocalizedString(@"Info.title", @"Info title");
        
		self.accessibilityLabel = TIBLE_UI_COMPONENT_INFO_VC_IDENTIFIER;
		self.navigationController.accessibilityLabel = TIBLE_UI_COMPONENT_INFO_VC_IDENTIFIER;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resetScale:)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
        
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarDidChangeFrame:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
	}
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated {

    if (self.scrollView == nil) {
        
        rect = self.view.bounds;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:rect];
        [self.scrollView setMaximumZoomScale:5];
        [self.scrollView setDelegate:self];
        
        [self.view.superview addSubview:self.scrollView];
        
        [self.scrollView addSubview:self.view];
        
        [self.scrollView setContentSize:rect.size];
        
        [self setButtons];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.view;
}

- (void)loadView {
    [super loadView];
	
	//place to load other xibs if need to.
	//can't load alert window xib here.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.scrollView setZoomScale:1.0];

}

//only used for iPad, where this screen is modal.
- (IBAction)dismissInfoScreen:(id)sender {
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
	
	self.alertWindow = nil;
	
    [self setStretchableAlertBackgroundImageView:nil];
    [self setStretchableAlertContentBackgroundImageView:nil];
    [self setPowerButton:nil];
    [self setAnalogButton:nil];
    [self setProcessingButton:nil];
    [super viewDidUnload];
}

- (void) dealloc{
	
	self.alertWindow = nil;
}

- (IBAction)dismissAlertWindow:(id)sender {
	
    self.tabBarController.view.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    
	[self.alertWindow removeFromSuperview];
	self.alertWindow = nil;
}

- (IBAction)showAlert:(id)sender {

    if ([sender tag] == 0) { //about
        
        UINib *nib = [UINib nibWithNibName:TIBLE_ABOUT_ALERT_WINDOW bundle:nil];
        [nib instantiateWithOwner:self options:nil];
     
		[self updateOrientationChange];
		
        [self.aboutTextView setText:NSLocalizedString(@"InfoScreen.About", @"About popup alert")];
    }
    else if ([sender tag] == 1) { // copyrights
        
        UINib *nib = [UINib nibWithNibName:TIBLE_COPYRIGHTS_ALERT_WINDOW bundle:nil];
        [nib instantiateWithOwner:self options:nil];
        
		[self updateOrientationChange];
		
        [self.copyrightTextView setText:NSLocalizedString(@"InfoScreen.Copyrights", @"Copyright popup alert")];
    }
    
	[self.stretchableAlertBackgroundImageView setImageForName:@"alert_view_background.png"
	 withLeftCapWidth:50 andTopCapHeight:50];
	//                                                    andInsets:UIEdgeInsetsMake(50, 50, 50, 50)];
    [self.stretchableAlertContentBackgroundImageView setImageForName:@"alert_view_content_background.png"
                                                           andInsets:UIEdgeInsetsMake(6, 4, 5, 6)];
    
	self.alertWindow.alpha = TIBLE_UI_COMPONENT_VISIBLE_ALPHA;
	self.alertWindow.hidden = NO;
	self.alertWindow.userInteractionEnabled = YES;
    
    float xPos = (self.view.window.center.x) - (self.alertWindow.frame.size.width / 2.0);
    float yPos = (self.view.window.center.y) - (self.alertWindow.frame.size.height / 2.0);

    self.tabBarController.view.userInteractionEnabled = NO;
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    
    [self.alertWindow setFrame:CGRectMake(xPos, yPos, self.alertWindow.frame.size.width, self.alertWindow.frame.size.height)];
}

- (IBAction)showSchematic:(id)sender {
    TIBLEAliasViewController *aliasVC = [[TIBLEAliasViewController alloc] init];
    
    NSString *urlLink = nil;
    NSString *pageTitle = nil;
	
    switch ([sender tag]) {
        case 0:
            pageTitle = NSLocalizedString(@"InfoScreen.Power", @"Power in uiwebview");
            urlLink = kTIURLPower;
            break;
        case 1:
            pageTitle = NSLocalizedString(@"InfoScreen.Analog", @"Analog in uiwebview");
            urlLink = kTIURLAnalog;
            break;
        case 2:
            pageTitle = NSLocalizedString(@"InfoScreen.BLE", @"Processing in uiwebview");
            urlLink = kTIURLProcessing;
            break;
        case 3:
            pageTitle = NSLocalizedString(@"InfoScreen.TISolutions", @"TI solutions in uiwebview");
            urlLink = kTIURLTISolutions;
            break;
    }
    
    [self.view.superview removeFromSuperview];
    self.scrollView = nil;
    
    [self resetScale:nil];

    [self.navigationController pushViewController:aliasVC animated:YES];
    [aliasVC loadPageWithURL:urlLink pageTitle:pageTitle];
}

#pragma mark - QLPreview

- (IBAction)showSchematicPDF:(id)sender {
    
	QLPreviewController * schematic = [[QLPreviewController alloc] init];

    [schematic setDelegate:self];
    [schematic setDataSource:self];
	
	[self presentViewController:schematic animated:YES completion:^{}];
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {

    NSString *path = [[NSBundle mainBundle] pathForResource:kSchematicFileName ofType:kFileExtensionPDF];
    
    return [NSURL fileURLWithPath:path];
}

#pragma mark - Orientation Change for windows

- (void) updateOrientationChange{
	
	if(self.alertWindow != nil){
		
		[self.alertWindow setOrientationToCurrentDeviceOrientation];
	}
	
	[self setButtons];
}

- (void) statusBarDidChangeFrame:(NSNotification *)notification {
    
    [self setButtons];
}

- (void)setButtons {
	
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    CGPoint power;
    CGPoint analog;
    CGPoint processing;
    
    CGSize powerSize;
    CGSize analogSize;
    CGSize processingSize;
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        power.x = 276.0f;
        power.y = 29.5f;
        
        analog.x = 520.0f;
        analog.y = 288.0f;
        
        processing.x = 290.0f;
        processing.y = 467.5;
        
        powerSize = CGSizeMake(270.0f, 259.0f);
        analogSize = CGSizeMake(250.0f, 234.0f);
        processingSize = CGSizeMake(227.0f, 217.0f);
    }
    else { // if the ipad is in portrait mode
        power.x = 57.0f;
        power.y = 66.0f;
        
        analog.x = 417.0f;
        analog.y = 382.0f;
        
        processing.x = 57.0f;
        processing.y = 634.0f;;
        
        powerSize = CGSizeMake(357.0f, 337.0f);
        analogSize = CGSizeMake(314.0f, 311.0f);
        processingSize = CGSizeMake(338.0f, 315.0f);
    }
    
    self.powerButton.frame = CGRectMake(power.x, power.y, powerSize.width, powerSize.height);
    self.analogButton.frame = CGRectMake(analog.x, analog.y, analogSize.width, analogSize.height);
    self.processingButton.frame = CGRectMake(processing.x, processing.y, processingSize.width, processingSize.height);
    
    [self resetScale:nil];
}

- (void)resetScale:(NSNotification *)notification {
	
    [UIView animateWithDuration:0.0 animations:^{
		
        self.view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        self.view.transform = CGAffineTransformIdentity;
    }];
    
    [self.scrollView setZoomScale:1.0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
