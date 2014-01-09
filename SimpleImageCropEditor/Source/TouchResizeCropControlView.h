//
//  TouchResizeCropControlView.h
//  SimpleImageCropEditor
//
//  Created by MobileSandbox1 on 1/9/14.
//  Copyright (c) 2014 MobileSandbox LLC. All rights reserved.


#import <UIKit/UIKit.h>

@interface TouchResizeCropControlView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic) CGPoint translation;
@property (nonatomic) CGPoint startPoint;

@end

@protocol TouchResizeCropControlDelegate <NSObject>

- (void)resizeConrolViewDidBeginResizing:(TouchResizeCropControlView *)resizeConrolView;
- (void)resizeConrolViewDidResize:(TouchResizeCropControlView *)resizeConrolView;
- (void)resizeConrolViewDidEndResizing:(TouchResizeCropControlView *)resizeConrolView;

@end
