/*
 *  TIBLEProgressView.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEProgressView.h"
#import "UIImageView+GeometryConversion.h"
#import "TIBLEStretchableImageView.h"
#import "UIImage+Resizable.h"

@interface TIBLEProgressView ()

- (CGPoint) currentValuePointInView;

@end

@implementation TIBLEProgressView

- (NSString *) getImageName{
	
	NSString * imageName = @"";
	
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	
	BOOL isiPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
	
	if(isiPad == YES){
		
		if(UIInterfaceOrientationIsLandscape(orientation)){
			
			imageName = @"progress-bar-landscape~ipad.png";
		}
		else{ //portrait
			
			imageName = @"progress-bar-portrait~ipad.png";
		}
	}
	else{ //iphone
		
		imageName = @"progress-bar.png";
	}
	
	return imageName;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	
    if (self) {
		
		NSString * imageName = [self getImageName];
		
		UIImage * regularImage = [UIImage imageNamed:imageName];
		
		UIEdgeInsets insets = UIEdgeInsetsMake(10, 2, 10, 2);
		UIImage * resizedImage = [regularImage duplicateImageWithCapInsets:insets];
		
		[self setImage: resizedImage];
		
		//self.contentMode = UIViewContentModeScaleAspectFill;
		
		self.normalizedValue = 0.5f;
    }
    return self;
}

- (void) colorProgress{
	
    float alpha = 0.65f;
    
    CGSize size = self.image.size;
    
    UIGraphicsBeginImageContextWithOptions(size, FALSE, 2);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.image drawAtPoint:CGPointZero blendMode:kCGBlendModeMultiply alpha:1.0];
    
    CGContextSetFillColorWithColor(context, self.progressColor.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeSourceAtop); // R = S*Da + D*(1 - Sa)
    CGContextSetAlpha(context, alpha);
    
    //key part
    float percentage = self.image.size.height * self.normalizedValue;
    
    //fill the progress
    CGContextFillRect(UIGraphicsGetCurrentContext(),
                      CGRectMake(CGPointZero.x,
								 size.height - percentage,
								 self.image.size.width,
								 size.height));
    
    //fill the rest to make consistent
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetBlendMode(context, kCGBlendModeSourceAtop); // R = S*Da + D*(1 - Sa)
    CGContextSetAlpha(context, alpha);
    
    
    CGContextFillRect(UIGraphicsGetCurrentContext(),
                      CGRectMake(CGPointZero.x,
								 CGPointZero.y,
								 self.image.size.width,
								 size.height - percentage));
    
    UIImage * tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    self.image = tintedImage;
	
	[self setNeedsDisplay];
}

- (CGPoint) currentValuePointInView{
	//get size of image (this does not account for scaling)
	CGSize size = self.image.size;
	
	//get percentage of progress based on image height (not accouting scaling)
	float percentage = self.image.size.height * self.normalizedValue;
	
	//since the image has been scaled, need to convert this point inside image to the image view.
	CGPoint pointInImage = CGPointMake(CGPointZero.x, size.height - percentage);
	CGPoint point = [self convertPointFromImage:pointInImage];
	
	return point;
}

@end
