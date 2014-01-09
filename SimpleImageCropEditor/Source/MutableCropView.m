//
//  MutableCropView.m
//  SimpleImageCropEditor
//
//  Created by MobileSandbox1 on 1/9/14.
//  Copyright (c) 2014 MobileSandbox LLC. All rights reserved.

#import "MutableCropView.h"

@implementation MutableCropView



@synthesize     image;
@synthesize     scrollView;
@synthesize     zoomingView;
@synthesize     imageView;
@synthesize     resizing;
@synthesize     cropRect;
@synthesize     cropRectView;
@synthesize     topOverlayView;
@synthesize     leftOverlayView;
@synthesize     rightOverlayView;
@synthesize     bottomOverlayView;
@synthesize     insetRect;
@synthesize     editingRect;




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {

        #if(PPTIE_Debug == 1 || MCV_Debug == 1)
        NSLog(@"        MutableCropView::commonInit");
        #endif
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.delegate = self;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleBottomMargin;
        self.scrollView.backgroundColor = [UIColor clearColor];
        
        
        //This value determines how large the content can be scaled.
        //     It must be greater than the minimum zoom scale for zooming to be enabled.
        //     The default value is 1.0.
        //A scale factor is a number which scales, or multiplies, some quantity. In the equation y=Cx,
        //   C is the scale factor for x. C is also the coefficient of x, and may be called the constant
        //   of proportionality of y to x.
        self.scrollView.maximumZoomScale = 2.5f;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.bounces = NO;
        self.scrollView.bouncesZoom = NO;
        self.scrollView.clipsToBounds = NO;
        
        [self addSubview:self.scrollView];
        
        self.cropRectView = [[CropView alloc] initWithFrame:self.scrollView.bounds];
        self.cropRectView.delegate = self;
        [self addSubview:self.cropRectView];
        
        self.topOverlayView = [[UIView alloc] init];
        self.topOverlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        [self addSubview:self.topOverlayView];
        
        self.leftOverlayView = [[UIView alloc] init];
        self.leftOverlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        [self addSubview:self.leftOverlayView];
        
        self.rightOverlayView = [[UIView alloc] init];
        self.rightOverlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        [self addSubview:self.rightOverlayView];
        
        self.bottomOverlayView = [[UIView alloc] init];
        self.bottomOverlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        [self addSubview:self.bottomOverlayView];
        


    }
    
    return self;
}




#pragma mark -



// If this is the UIView hitTest or where the responder chain
// ends up with a touch response. We need to handle it for panning
//    returns the UIView that is touched.
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::hitTest");
    #endif
    
    // just in case there is an error and the layer is not enabled.
    if (!self.userInteractionEnabled)
    {
        return nil;
    }
    
    // get the child view (CropView) with point and event from UIView
    // utility hitView
    UIView *localHitView = [self.cropRectView hitTest:[self convertPoint:point
                                          toView:self.cropRectView]
                                       withEvent:event];
    
    // if not nil then it is the child view where the touch landed and return that UIView
    if (localHitView)
    {
        return localHitView;
    }
    
    // If not in the Child View (CropView) then where on the scrollview (zoomingView) is it?
    // This gives us the point outside of the zoom to assist in panning touch gesters
    CGPoint locationInImageView = [self convertPoint:point toView:self.zoomingView];
    
    // panning view, layer below, the cropview touch point associated with the
    // outer portions of the view.
    CGPoint zoomedPoint = CGPointMake(locationInImageView.x * self.scrollView.zoomScale,
                                      locationInImageView.y * self.scrollView.zoomScale);
    
    // if we are touching the outer portion return the scroll view as the UIView
    if (CGRectContainsPoint(self.zoomingView.frame, zoomedPoint))
    {
        return self.scrollView;
    }
    
    
    // else you are outside the scrollview and cropview in front.
    // The event needs to be handled by the superview hitTest in case
    // there is processing to be done.
    return [super hitTest:point withEvent:event];

}



// call layout subview on this scrollView.
- (void)layoutSubviews
{
    
    [super layoutSubviews];
    
    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::layoutSubviews");
    #endif

    // If the image has not been initialized, then return with
    // not work being done.
    if (!(self.image) )
    {
        return;//return because the image is not nil
    }
    
    // CGRectInset : Returns a rectangle that is smaller or larger than the source rectangle,
    //               with the same center point.
    // Rect for the MutableCropView, MarginLeft, MarginTop
    // We are returning a rect that is smaller than the Mutable Crop View
    self.editingRect = CGRectInset(self.bounds, MarginLeft, MarginTop);
    
    if (!self.imageView)
    {
        self.insetRect = CGRectInset(self.bounds, MarginLeft, MarginTop);
        [self setupImageView];
    }
    
    // process a resizing action if we are resizing at this time due to touch gesters
    // and init of controllers and views for display.
    if (!self.isResizing)
    {
        [self layoutCropRectViewWithCropRect:self.scrollView.frame];
        [self zoomToCropRect:self.scrollView.frame];
    }
    
}





- (void)layoutCropRectViewWithCropRect:(CGRect)localCropRect
{
    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::layoutCropRectViewWithCropRect");
    #endif

    
     self.cropRectView.frame = localCropRect;
     [self layoutOverlayViewsWithCropRect:localCropRect];
    

}






- (void)layoutOverlayViewsWithCropRect:(CGRect)localCropRect
{
    
    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::layoutOverlayViewsWithCropRect");
    #endif
    
    
    self.topOverlayView.frame = CGRectMake(0.0f,
                                           0.0f,
                                           CGRectGetWidth(self.bounds),
                                           CGRectGetMinY(localCropRect));
    
    
    self.leftOverlayView.frame = CGRectMake(0.0f,
                                            CGRectGetMinY(localCropRect),
                                            CGRectGetMinX(localCropRect),
                                            CGRectGetHeight(localCropRect));
    
    
    self.rightOverlayView.frame = CGRectMake(CGRectGetMaxX(localCropRect),
                                             CGRectGetMinY(localCropRect),
                                             CGRectGetWidth(self.bounds) - CGRectGetMaxX(localCropRect),
                                             CGRectGetHeight(localCropRect));
    
    
    self.bottomOverlayView.frame = CGRectMake(0.0f,
                                              CGRectGetMaxY(localCropRect),
                                              CGRectGetWidth(self.bounds),
                                              CGRectGetHeight(self.bounds) - CGRectGetMaxY(localCropRect));

    
}



- (void)setupImageView
{
    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::setupImageView");
    #endif
    
    //This is useful when attempting to fit the naturalSize property of an
    //   AVPlayerItem object within the bounds of another CALayer.
    //   You would typically use the return value of this function as an
    //   AVPlayerLayer frame property value. For example:
    //example:  myPlayerLayer.frame = AVMakeRectWithAspectRatioInsideRect(myPlayerItem.naturalSize, mySuperLayer.bounds);
    CGRect localCropRect = AVMakeRectWithAspectRatioInsideRect(self.image.size, self.insetRect);

    self.scrollView.frame = localCropRect;
    self.scrollView.contentSize = localCropRect.size;
     
    self.zoomingView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
    self.zoomingView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.zoomingView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.zoomingView.bounds];
    self.imageView.backgroundColor = [UIColor clearColor];

    //The option to scale the content to fit the size of the view by maintaining
    //    the aspect ratio. Any remaining area of the view’s bounds is transparent.
    // place the image in a scaled aspect view into the 'imageView'
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    // since the content Mode is scale aspect fit to zoom bounds, we assign and the
    // the image will scale to the zoom view aspect and rectangle size.
    self.imageView.image = self.image;
    
    // now add the imageView
    [self.zoomingView addSubview:self.imageView];
    
}







#pragma mark -


- (UIImage *)croppedImage
{
    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::croppedImage");
    #endif
    
    CGImageRef localcroppedImage = CGImageCreateWithImageInRect(self.image.CGImage, self.zoomedCropRect);
    
    UIImage *localImage = [UIImage imageWithCGImage:localcroppedImage scale:1.0f orientation:UIImageOrientationUp];
    
    CGImageRelease(localcroppedImage);
    return localImage;
}




- (CGRect)zoomedCropRect
{

    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::zoomedCropRect");
    #endif
    
    CGRect localCropRect = [self convertRect:self.scrollView.frame toView:self.zoomingView];
    CGSize size = self.image.size;
    
    CGFloat ratio = 1.0f;
    ratio = CGRectGetWidth(AVMakeRectWithAspectRatioInsideRect(self.image.size, self.insetRect)) / size.width;

    CGRect zoomedCropRect = CGRectMake(localCropRect.origin.x / ratio,
                                        localCropRect.origin.y / ratio,
                                        localCropRect.size.width / ratio,
                                        localCropRect.size.height / ratio);
    
    return zoomedCropRect;

}





- (CGRect)cappedCropRectInImageRectWithCropRectView:(CropView *)localCropRectView
{
    
    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::cappedCropRectInImageRectWithCropRectView");
    #endif

     CGRect localCropRect = localCropRectView.frame;
     
     CGRect rect = [self convertRect:localCropRect toView:self.scrollView];
     
     if (CGRectGetMinX(rect) < CGRectGetMinX(self.zoomingView.frame))
     {
     
     
     localCropRect.origin.x = CGRectGetMinX([self.scrollView convertRect:self.zoomingView.frame toView:self]);
     CGFloat cappedWidth = CGRectGetMaxX(rect);
     
     localCropRect.size = CGSizeMake(cappedWidth,localCropRect.size.height * (cappedWidth/localCropRect.size.width));
     
     
     
     }
     if (CGRectGetMinY(rect) < CGRectGetMinY(self.zoomingView.frame))
     {
     
     localCropRect.origin.y = CGRectGetMinY([self.scrollView convertRect:self.zoomingView.frame toView:self]);
     CGFloat cappedHeight =  CGRectGetMaxY(rect);
     
     
     localCropRect.size = CGSizeMake(localCropRect.size.width * (cappedHeight / localCropRect.size.height),cappedHeight);
     
     
     }
     if (CGRectGetMaxX(rect) > CGRectGetMaxX(self.zoomingView.frame))
     {
     
     CGFloat cappedWidth = CGRectGetMaxX([self.scrollView convertRect:self.zoomingView.frame toView:self]) - CGRectGetMinX(localCropRect);
     
     localCropRect.size = CGSizeMake(cappedWidth, localCropRect.size.height * (cappedWidth/localCropRect.size.width));
     
     
     }
     if (CGRectGetMaxY(rect) > CGRectGetMaxY(self.zoomingView.frame))
     {
     
     CGFloat cappedHeight =  CGRectGetMaxY([self.scrollView convertRect:self.zoomingView.frame toView:self]) - CGRectGetMinY(localCropRect);
     
     localCropRect.size = CGSizeMake( localCropRect.size.width * (cappedHeight / localCropRect.size.height), cappedHeight);
     
     }
     
     return localCropRect;

}






- (void)automaticZoomIfEdgeTouched:(CGRect)localCropRect
{

    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::automaticZoomIfEdgeTouched");
    #endif
    
    if (CGRectGetMinX(localCropRect) < CGRectGetMinX(self.editingRect) - 5.0f ||
        CGRectGetMaxX(localCropRect) > CGRectGetMaxX(self.editingRect) + 5.0f ||
        CGRectGetMinY(localCropRect) < CGRectGetMinY(self.editingRect) - 5.0f ||
        CGRectGetMaxY(localCropRect) > CGRectGetMaxY(self.editingRect) + 5.0f)
    
    {

        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self zoomToCropRect:self.cropRectView.frame];
                         } completion:^(BOOL finished)
                            {
                             
                            }];
        
    
    }
    
    
}



#pragma mark -   Handlers for Touch Events


- (void)cropRectViewDidBeginEditing:(CropView *)cropRectView
{
    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::cropRectViewDidBeginEditing");
    #endif
    
    self.resizing = YES;

}



- (void)cropRectViewEditingChanged:(CropView *)localCropRectView
{
    
    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::cropRectViewEditingChanged");
    #endif
    
    CGRect localCropRect = [self cappedCropRectInImageRectWithCropRectView:localCropRectView];
    
    [self layoutCropRectViewWithCropRect:localCropRect];
    
    [self automaticZoomIfEdgeTouched:localCropRect];

}





//  Starting point after the GestureRecognizerStateEnded for the
//  crop view, and the Resize Controller.  Resize Controller calls
//  back to the crop view, then back to the MutableCropView
//  on gesture recognizer -- to call in scrollview to zoom in.

- (void)cropRectViewDidEndEditing:(CropView *)cropRectView
{
    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::cropRectViewDidEndEditing");
    #endif

    self.resizing = NO;  // trigger to allow actual resizing.
    
    // Take the loaded CropView and ask to zoom into the crop area, center
    // it on the parent view, or in this case the scrollview.
    [self zoomToCropRect:self.cropRectView.frame];

}






- (void)zoomToCropRect:(CGRect)localCropToRect
{
    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::zoomToCropRect");
    #endif
    
    
    // If we are the same size as the scrollview, then no zoom in and centering
    //   is necessary.
    if (CGRectEqualToRect(self.scrollView.frame, localCropToRect))
    {
        return;
    }
    
    //grab the Rectangle to zoom to
    CGFloat width = CGRectGetWidth(localCropToRect);
    CGFloat height = CGRectGetHeight(localCropToRect);
    
    // set the minimum scale size
    CGFloat scale = MIN(CGRectGetWidth(self.editingRect) / width, CGRectGetHeight(self.editingRect) / height);
    
    
    // set the scaled size of width and height
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    
    // set the cropRect to a new place.
    CGRect localCropRect = CGRectMake((CGRectGetWidth(self.bounds) - scaledWidth) / 2,
                                 (CGRectGetHeight(self.bounds) - scaledHeight) / 2,
                                 scaledWidth,
                                 scaledHeight);
    
    
    // set zoom rect to new Rectangle
    CGRect localZoomRect = [self convertRect:localCropToRect toView:self.zoomingView];
    
    // set the zoomRect
    localZoomRect.size.width = CGRectGetWidth(localCropRect) / (self.scrollView.zoomScale * scale);
    localZoomRect.size.height = CGRectGetHeight(localCropRect) / (self.scrollView.zoomScale * scale);

    //animate the new crop view and scroll view to a new position.
    //Using the layoutCropRectViewWithCropRect
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         self.scrollView.bounds = localCropRect;
                         [self.scrollView zoomToRect:localZoomRect animated:NO];
                         [self layoutCropRectViewWithCropRect:cropRect];
                         
                                 } completion:^(BOOL finished)
                                    {
                                        
                                    }];
    
}



#pragma mark -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::shouldRecognizeSimultaneouslyWithGestureRecognizer");
    #endif
    
    return YES;
}


#pragma mark -

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    
    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::viewForZoomingInScrollView");
    #endif
    
    return self.zoomingView;

}


#pragma mark -

- (void)scrollViewWillEndDragging:(UIScrollView *)localScrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{

    #if(PPTIE_Debug == 1 || MCV_Debug == 1)
    NSLog(@"        MutableCropView::viewForZoomingInScrollView");
    #endif
    
    CGPoint contentOffset = localScrollView.contentOffset;
    *targetContentOffset = contentOffset;
}


@end

