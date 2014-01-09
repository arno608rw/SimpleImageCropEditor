//
//  MutableCropView.h
//  SimpleImageCropEditor
//
//  Created by MobileSandbox1 on 1/9/14.
//  Copyright (c) 2014 MobileSandbox LLC. All rights reserved.


#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "TouchResizeCropControlView.h"
#import "CropView.h"
#import <UIKit/UIKit.h>
#import "Common.h"




static const CGFloat MarginTop = 42.0f;
static const CGFloat MarginBottom = MarginTop;
static const CGFloat MarginLeft = 20.0f;
static const CGFloat MarginRight = MarginLeft;


@interface MutableCropView : UIView  <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    UIImage *image;// The passed image from the crop and grayscale editor
    UIScrollView *scrollView;
    CGRect cropRect;
    UIView *zoomingView;
    UIImageView *imageView;
    CropView *cropRectView;
    UIView *topOverlayView;
    UIView *leftOverlayView;
    UIView *rightOverlayView;
    UIView *bottomOverlayView;
    CGRect insetRect;
    CGRect editingRect;
    BOOL resizing;
}


@property (nonatomic) UIImage *image;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) CGRect cropRect;
@property (nonatomic) UIView *zoomingView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) CropView *cropRectView;
@property (nonatomic) UIView *topOverlayView;
@property (nonatomic) UIView *leftOverlayView;
@property (nonatomic) UIView *rightOverlayView;
@property (nonatomic) UIView *bottomOverlayView;
@property (nonatomic) CGRect insetRect;
@property (nonatomic) CGRect editingRect;
@property (nonatomic, getter = isResizing) BOOL resizing;



- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
- (void)layoutSubviews;
- (void)layoutCropRectViewWithCropRect:(CGRect)cropRect;
- (void)layoutOverlayViewsWithCropRect:(CGRect)cropRect;
- (void)setupImageView;
- (UIImage *)croppedImage;
- (CGRect)zoomedCropRect;
- (void)automaticZoomIfEdgeTouched:(CGRect)cropRect;
- (void)cropRectViewDidBeginEditing:(CropView *)cropRectView;
- (void)cropRectViewEditingChanged:(CropView *)cropRectView;
- (void)cropRectViewDidEndEditing:(CropView *)cropRectView;
- (void)zoomToCropRect:(CGRect)cropToRect;
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;
- (CGRect)cappedCropRectInImageRectWithCropRectView:(CropView *)cropRectView;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
            shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;




@end
