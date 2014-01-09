//
//  TouchResizeCropControlView.m
//  SimpleImageCropEditor
//
//  Created by MobileSandbox1 on 1/9/14.
//  Copyright (c) 2014 MobileSandbox LLC. All rights reserved.


#import "TouchResizeCropControlView.h"


@interface TouchResizeCropControlView ()

@end



@implementation TouchResizeCropControlView

@synthesize delegate;
@synthesize translation;
@synthesize startPoint;


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 44.0f, 44.0f)];
    
    if (self)
    {
        
        self.backgroundColor = [UIColor clearColor];
        self.exclusiveTouch = YES;
        
        // UI Pan Gesture Recognizer - setup a callback handler
        UIPanGestureRecognizer *gestureRecognizer =
            [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        
        
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}




- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        
        
        #if(PPTIE_Debug == 1 || TC_Debug == 1)
        NSLog(@"CropController :: handlePan:  UIGestureRecognizerStateBegan");
        #endif
        
        
        CGPoint translationInView = [gestureRecognizer translationInView:self.superview];
        self.startPoint = CGPointMake(roundf(translationInView.x), translationInView.y);
        
        if ([self.delegate respondsToSelector:@selector(resizeConrolViewDidBeginResizing:)])
        {
            [self.delegate resizeConrolViewDidBeginResizing:self];
        }
        
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        
        #if(PPTIE_Debug == 1 || TC_Debug == 1)
        NSLog(@"CropController :: handlePan:  UIGestureRecognizerStateChanged");
        #endif
        
        CGPoint localTranslation = [gestureRecognizer translationInView:self.viewForBaselineLayout];
        
        self.translation = CGPointMake(roundf(self.startPoint.x + localTranslation.x),
                                       roundf(self.startPoint.y + localTranslation.y));
        
        if ([self.delegate respondsToSelector:@selector(resizeConrolViewDidResize:)])
        {
            [self.delegate resizeConrolViewDidResize:self];
        }
        
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
             gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        
        #if(PPTIE_Debug == 1 || TC_Debug == 1)
        NSLog(@"CropController :: handlePan:  UIGestureRecognizerStateEnded || UIGestureRecognizerStateCancelled");
        #endif
        
        if ([self.delegate respondsToSelector:@selector(resizeConrolViewDidEndResizing:)])
        {
            [self.delegate resizeConrolViewDidEndResizing:self];
        }
    }
    
    
}


@end
