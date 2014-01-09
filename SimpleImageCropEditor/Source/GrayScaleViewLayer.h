//
//  GrayScaleViewLayer.h
//  SimpleImageCropEditor
//
//  Created by MobileSandbox1 on 1/9/14.
//  Copyright (c) 2014 MobileSandbox LLC. All rights reserved.


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Common.h"


@interface GrayScaleViewLayer : UIView
{
    UIImage *backgroundImage;
}

@property (nonatomic) UIImage * backgroundImage;

@end
