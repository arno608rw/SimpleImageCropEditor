//
//  GrayScaleEditorViewController.h
//  SimpleImageCropEditor
//
//  Created by MobileSandbox1 on 1/9/14.
//  Copyright (c) 2014 MobileSandbox LLC. All rights reserved.


#import <UIKit/UIKit.h>
#import "GrayScaleViewLayer.h"
#import "Common.h"




@interface GrayScaleEditorViewController : UIViewController  <UIActionSheetDelegate >
{
    
    UIImageView * grayScaleImage;
    UIImageView * mutableImage;
    UIView *containerView;
    
    GrayScaleViewLayer *grayScaleImageView;//UIView Object

}


@property (nonatomic, retain)  UIImageView * grayScaleImage;
@property (nonatomic, retain)  UIImageView *  mutableImage;
@property (nonatomic, retain)  UIView *containerView;
@property (nonatomic, weak) id grayScaleDelegate;
@property (nonatomic,retain) GrayScaleViewLayer *grayScaleImageView;


- (void) accept;
- (void) cancel;

- (UIImage *)scaleToSize:(CGSize)targetSize;

@end





@protocol GrayScaleControllerDelegate <NSObject>

- (void)grayScaleViewController:(GrayScaleEditorViewController *)controller
                                didFinishGrayScaleImageChange:(UIImage *)alteredImage;

- (void)grayScaleViewControllerDidCancel:(GrayScaleEditorViewController *)controller;

@end