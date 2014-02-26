/*
 *  TIBLEStretchableImageView.m
 *  TI BLE Sensor App
 *  05/05/13
 *
 *  Copyright (c) 2013 Texas Instruments. All rights reserved.
 *  Created under contract for TI by Krasamo LLC (info@krasamo.com).
 *
 */

#import "TIBLEStretchableImageView.h"
#import "UIImage+Resizable.h"

@implementation TIBLEStretchableImageView

-(id) initWithCoder:(NSCoder *)aDecoder{
	
	self = [super initWithCoder:aDecoder];
	
	if(self != nil){
		
	}
	
	return self;
}

- (void) setImageForName: (NSString *) imageName andInsets:(UIEdgeInsets) edgeInsets{
	
	//create image view
	[self createImageView];
	
	//get resized image
	UIImage * image = [UIImage imageNamed:imageName];
	UIImage * resizedImage = [image duplicateImageWithCapInsets:edgeInsets];
	
	//set image inside image view
	self.imageView.image = resizedImage;
	
	//add image view to view
	[self addSubview:self.imageView];
}

- (void) setImageForName: (NSString *) imageName
		withLeftCapWidth: (NSInteger) leftCap
		 andTopCapHeight: (NSInteger) topCap{

	//create image view
	[self createImageView];
	
	//get resized image
	UIImage * image = [UIImage imageNamed:imageName];
	UIImage * resizedImage = [image duplicateImageWithLeftCapWidth:leftCap
												   andTopCapHeight:topCap];
	
	//set image inside image view
	self.imageView.image = resizedImage;
	
	//add image view to view
	[self addSubview:self.imageView];
}

#pragma Internal

- (void) createImageView{
	
	//create image view
	CGRect frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
	self.imageView = [[UIImageView alloc] initWithFrame:frame];
	
	self.imageView.contentMode = UIViewContentModeScaleToFill;
	self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}
@end
