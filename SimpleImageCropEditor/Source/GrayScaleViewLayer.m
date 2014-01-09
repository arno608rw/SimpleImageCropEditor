//
//  GrayScaleViewLayer.m
//  SimpleImageCropEditor
//
//  Created by MobileSandbox1 on 1/9/14.
//  Copyright (c) 2014 MobileSandbox LLC. All rights reserved.

#import "GrayScaleViewLayer.h"

@implementation GrayScaleViewLayer

@synthesize backgroundImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    
        // Initialization code
    }
    return self;
}




// Only override drawRect: if you perform custom drawing.
- (void)drawRect:(CGRect)rect
{
    UIImage *img = self.backgroundImage;
    [img drawInRect:rect];
    [self setNeedsDisplay];
    
}


@end
