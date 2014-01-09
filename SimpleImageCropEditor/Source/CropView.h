//
//  CropView.h
//  SimpleImageCropEditor
//
//  Created by MobileSandbox1 on 1/9/14.
//  Copyright (c) 2014 MobileSandbox LLC. All rights reserved.

#import <UIKit/UIKit.h>
#import "TouchResizeCropControlView.h"
#import "Common.h"



@interface CropView : UIView

    @property (nonatomic, weak) id delegate;
    @property (nonatomic) BOOL showsGridMajor;
    @property (nonatomic) BOOL showsGridMinor;

    @property (nonatomic) BOOL keepingAspectRatio;

    @property (nonatomic) TouchResizeCropControlView *topLeftCornerView;
    @property (nonatomic) TouchResizeCropControlView *topRightCornerView;
    @property (nonatomic) TouchResizeCropControlView *bottomLeftCornerView;
    @property (nonatomic) TouchResizeCropControlView *bottomRightCornerView;
    @property (nonatomic) TouchResizeCropControlView *topEdgeView;
    @property (nonatomic) TouchResizeCropControlView *leftEdgeView;
    @property (nonatomic) TouchResizeCropControlView *bottomEdgeView;
    @property (nonatomic) TouchResizeCropControlView *rightEdgeView;

    @property (nonatomic) CGRect initialRect;
    @property (nonatomic) CGFloat fixedAspectRatio;

@end



@protocol CropViewDelegate <NSObject>

- (void)cropRectViewDidBeginEditing:(CropView *)cropRectView;
- (void)cropRectViewEditingChanged:(CropView *)cropRectView;
- (void)cropRectViewDidEndEditing:(CropView *)cropRectView;

@end

