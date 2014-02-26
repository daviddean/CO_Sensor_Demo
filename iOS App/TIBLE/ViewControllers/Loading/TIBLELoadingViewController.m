/*
 *  TIBLELoadingViewController.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLELoadingViewController.h"
#import "TIBLEUIConstants.h"

@interface TIBLELoadingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *waitLabel;
@property (weak, nonatomic) IBOutlet UILabel *readingLabel;

@end

@implementation TIBLELoadingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
	if (self) {
        
		self.accessibilityLabel = TIBLE_UI_COMPONENT_LOADING_VC_IDENTIFIER;
		self.navigationController.accessibilityLabel = TIBLE_UI_COMPONENT_LOADING_VC_IDENTIFIER;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.waitLabel setText:NSLocalizedString(@"Loading.PleaseWait.Label", nil)];
    [self.readingLabel setText:
        NSLocalizedString(@"Loading.Reading.Label", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setWaitLabel:nil];
    [self setReadingLabel:nil];
    [super viewDidUnload];
}
@end
