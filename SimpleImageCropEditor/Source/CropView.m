//
//  CropView.m
//  SimpleImageCropEditor
//
//  Created by MobileSandbox1 on 1/9/14.
//  Copyright (c) 2014 MobileSandbox LLC. All rights reserved.


#import "CropView.h"

@implementation CropView


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if (self)
    {
        
        self.backgroundColor = [UIColor clearColor];
        
        
        
        //UIViewContentModeRedraw
        //  The option to redisplay the view when the bounds change by
        //  invoking the setNeedsDisplay method.
        //  Available in iOS 2.0 and later.
        self.contentMode = UIViewContentModeRedraw;
        
        self.showsGridMajor = NO;
        self.showsGridMinor = NO;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, -6.0f, -6.0f)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.image = [[UIImage imageNamed:@"PhotoCropBorder_Stolen"]
                           resizableImageWithCapInsets:UIEdgeInsetsMake(23.0f, 23.0f, 23.0f, 23.0f)];
        
        [self addSubview:imageView];
        
        self.topLeftCornerView = [[TouchResizeCropControlView alloc] init];
        self.topLeftCornerView.delegate = self;
        [self addSubview:self.topLeftCornerView];
        
        self.topRightCornerView = [[TouchResizeCropControlView alloc] init];
        self.topRightCornerView.delegate = self;
        [self addSubview:self.topRightCornerView];
        
        self.bottomLeftCornerView = [[TouchResizeCropControlView alloc] init];
        self.bottomLeftCornerView.delegate = self;
        [self addSubview:self.bottomLeftCornerView];
        
        self.bottomRightCornerView = [[TouchResizeCropControlView alloc] init];
        self.bottomRightCornerView.delegate = self;
        [self addSubview:self.bottomRightCornerView];
        
        self.topEdgeView = [[TouchResizeCropControlView alloc] init];
        self.topEdgeView.delegate = self;
        [self addSubview:self.topEdgeView];
        
        self.leftEdgeView = [[TouchResizeCropControlView alloc] init];
        self.leftEdgeView.delegate = self;
        [self addSubview:self.leftEdgeView];
        
        self.bottomEdgeView = [[TouchResizeCropControlView alloc] init];
        self.bottomEdgeView.delegate = self;
        [self addSubview:self.bottomEdgeView];
        
        self.rightEdgeView = [[TouchResizeCropControlView alloc] init];
        self.rightEdgeView.delegate = self;
        [self addSubview:self.rightEdgeView];

    }
    
    return self;
}





#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{

    #if(PPTIE_Debug == 1 || CV_Debug == 1)
    NSLog(@"hitTest");
    #endif
    
    NSArray *subviews = self.subviews;
    for (UIView *subview in subviews)
    {
        
        if ([subview isKindOfClass:[TouchResizeCropControlView class]])
        {
            if (CGRectContainsPoint(subview.frame, point))
            {
                return subview;
            }
        }
    }
    
    return nil;
}







- (void)drawRect:(CGRect)rect
{

    #if(PPTIE_Debug == 1 || CV_Debug == 1)
    NSLog(@"drawRect");
    #endif
    
    [super drawRect:rect];

}




// #5 on the profiler
- (void)layoutSubviews
{
    
    #if(PPTIE_Debug == 1 || CV_Debug == 1)
    NSLog(@"layoutSubviews");
    #endif
    
    [super layoutSubviews];
    
    self.topLeftCornerView.frame = (CGRect){CGRectGetWidth(self.topLeftCornerView.bounds) / -2,
        CGRectGetHeight(self.topLeftCornerView.bounds) / -2,
        self.topLeftCornerView.bounds.size};
    
    self.topRightCornerView.frame = (CGRect){CGRectGetWidth(self.bounds) - CGRectGetWidth(self.topRightCornerView.bounds) / 2,
        CGRectGetHeight(self.topRightCornerView.bounds) / -2,
        self.topLeftCornerView.bounds.size};
    
    self.bottomLeftCornerView.frame = (CGRect){CGRectGetWidth(self.bottomLeftCornerView.bounds) / -2,
        CGRectGetHeight(self.bounds) - CGRectGetHeight(self.bottomLeftCornerView.bounds) / 2,
        self.bottomLeftCornerView.bounds.size};
    
    self.bottomRightCornerView.frame = (CGRect){CGRectGetWidth(self.bounds) - CGRectGetWidth(self.bottomRightCornerView.bounds) / 2,
        CGRectGetHeight(self.bounds) - CGRectGetHeight(self.bottomRightCornerView.bounds) / 2,
        self.bottomRightCornerView.bounds.size};
    
    self.topEdgeView.frame = (CGRect){CGRectGetMaxX(self.topLeftCornerView.frame),
        CGRectGetHeight(self.topEdgeView.frame) / -2,
        CGRectGetMinX(self.topRightCornerView.frame) - CGRectGetMaxX(self.topLeftCornerView.frame),
        CGRectGetHeight(self.topEdgeView.bounds)};
    
    self.leftEdgeView.frame = (CGRect){CGRectGetWidth(self.leftEdgeView.frame) / -2,
        CGRectGetMaxY(self.topLeftCornerView.frame), CGRectGetWidth(self.leftEdgeView.bounds),
        CGRectGetMinY(self.bottomLeftCornerView.frame) - CGRectGetMaxY(self.topLeftCornerView.frame)};
    
    self.bottomEdgeView.frame = (CGRect){CGRectGetMaxX(self.bottomLeftCornerView.frame),
        CGRectGetMinY(self.bottomLeftCornerView.frame),
        CGRectGetMinX(self.bottomRightCornerView.frame) - CGRectGetMaxX(self.bottomLeftCornerView.frame),
        CGRectGetHeight(self.bottomEdgeView.bounds)};
    
    self.rightEdgeView.frame = (CGRect){CGRectGetWidth(self.bounds) - CGRectGetWidth(self.rightEdgeView.bounds) / 2,
        CGRectGetMaxY(self.topRightCornerView.frame),
        CGRectGetWidth(self.rightEdgeView.bounds),
        CGRectGetMinY(self.bottomRightCornerView.frame) - CGRectGetMaxY(self.topRightCornerView.frame)};

}



#pragma mark - Resize Support

// This is for pan support
- (void)resizeConrolViewDidBeginResizing:(TouchResizeCropControlView *)resizeConrolView
{
    
    #if(PPTIE_Debug == 1 || CV_Debug == 1)
    NSLog(@"resizeConrolViewDidBeginResizing");
    #endif
    
    self.initialRect = self.frame;
    
    if ([self.delegate respondsToSelector:@selector(cropRectViewDidBeginEditing:)]) {
        [self.delegate cropRectViewDidBeginEditing:self];
    }
}





// number 1 called function calling rect with resize.
- (void)resizeConrolViewDidResize:(TouchResizeCropControlView *)resizeConrolView
{
    
    #if(PPTIE_Debug == 1 || CV_Debug == 1)
    NSLog(@"resizeConrolViewDidResize");
    #endif
    
    self.frame = [self cropRectMakeWithResizeControlView:resizeConrolView];
    
    if ([self.delegate respondsToSelector:@selector(cropRectViewEditingChanged:)]) {
        [self.delegate cropRectViewEditingChanged:self];
    }
}







// implementation of delegate callback from the resize control object.
- (void)resizeConrolViewDidEndResizing:(TouchResizeCropControlView *)resizeConrolView
{
    
    #if(PPTIE_Debug == 1 || CV_Debug == 1)
    NSLog(@"resizeConrolViewDidEndResizing");
    #endif
    
    if ([self.delegate respondsToSelector:@selector(cropRectViewDidEndEditing:)]) {
        [self.delegate cropRectViewDidEndEditing:self];//
    }
}




// top ten called function
- (CGRect)cropRectMakeWithResizeControlView:(TouchResizeCropControlView *)resizeControlView
{
    
    #if(PPTIE_Debug == 1 || CV_Debug == 1)
    NSLog(@"cropRectMakeWithResizeControlView");
    #endif
    
    CGRect rect = self.frame;
    
    if (resizeControlView == self.topEdgeView)
    {
        
        #if(PPTIE_Debug == 1 || CV_Debug == 1)
        NSLog(@"if (resizeControlView == self.topEdgeView) == T");
        #endif
        
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.y - 20.0f,
                          CGRectGetWidth(self.initialRect),
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
        
    }
    else if (resizeControlView == self.leftEdgeView)
    {
        
        
        #if(PPTIE_Debug == 1 || CV_Debug == 1)
        NSLog(@"else if (resizeControlView == self.leftEdgeView) == T ");
        #endif
        
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect));

        
    }
    else if (resizeControlView == self.bottomEdgeView)
    {
        
        
        #if(PPTIE_Debug == 1 || CV_Debug == 1)
        NSLog(@"else if (resizeControlView == self.bottomEdgeView) == T ");
        #endif

        
        
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect),
                          CGRectGetHeight(self.initialRect) + resizeControlView.translation.y);
        
         
    }
    else if (resizeControlView == self.rightEdgeView)
    {

        
        #if(PPTIE_Debug == 1 || CV_Debug == 1)
        NSLog(@"else if (resizeControlView == self.rightEdgeView) == T ");
        #endif

        
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect));
         
    } else if (resizeControlView == self.topLeftCornerView)
    {
        
        
        #if(PPTIE_Debug == 1 || CV_Debug == 1)
        NSLog(@"else if (resizeControlView == self.topLeftCornerView) == T ");
        #endif
        
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
        
    }
    else if (resizeControlView == self.topRightCornerView)
    {
        
        
        #if(PPTIE_Debug == 1 || CV_Debug == 1)
        NSLog(@"else if (resizeControlView ==  self.topRightCornerView) == T");
        #endif
        
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                          CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
        
        
    }
    else if (resizeControlView == self.bottomLeftCornerView)
    {
        
        
        #if(PPTIE_Debug == 1 || CV_Debug == 1)
        NSLog(@"else if (resizeControlView ==  bottomLeftCornerView) == T");
        #endif
        
    
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) + resizeControlView.translation.y);
        
         
    }
    else if (resizeControlView == self.bottomRightCornerView)
    {
        
        
        #if(PPTIE_Debug == 1 || CV_Debug == 1)
        NSLog(@"else if (resizeControlView ==  bottomRightCornerView) == T");
        #endif
        
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) + resizeControlView.translation.y);
        
    }
    
    CGFloat minWidth = CGRectGetWidth(self.leftEdgeView.bounds) + CGRectGetWidth(self.rightEdgeView.bounds);
    if (CGRectGetWidth(rect) < minWidth)
    {
        
        #if(PPTIE_Debug == 1 || CV_Debug == 1)
        NSLog(@"if (CGRectGetWidth(rect) < minWidth) == T");
        #endif

        
        rect.origin.x = CGRectGetMaxX(self.frame) - minWidth;
        rect.size = CGSizeMake(minWidth,
                               !self.fixedAspectRatio ? rect.size.height : rect.size.height * (minWidth / rect.size.width));
    }
    
    CGFloat minHeight = CGRectGetHeight(self.topEdgeView.bounds) + CGRectGetHeight(self.bottomEdgeView.bounds);
    if (CGRectGetHeight(rect) < minHeight)
    {
        
        #if(PPTIE_Debug == 1 || CV_Debug == 1)
        NSLog(@"if (CGRectGetWidth(rect) < minHeight) == T");
        #endif
        
        rect.origin.y = CGRectGetMaxY(self.frame) - minHeight;
        rect.size = CGSizeMake(!self.fixedAspectRatio ? rect.size.width : rect.size.width * (minHeight / rect.size.height),
                               minHeight);
    }

    return rect;
    
}


@end

