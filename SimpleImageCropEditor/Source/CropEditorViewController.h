//
//  CropEditorViewController.h
//  SimpleImageCropEditor
//
//  Created by MobileSandbox1 on 1/9/14.
//  Copyright (c) 2014 MobileSandbox LLC. All rights reserved.


// (MFF) 12-17-2013
// This is the Container View and Controller that sits in the Root Container view.
// This class owns the image and crop features and action/controller.
// Manages the returned cropped image and is returned a new image whether
// cropped or not.



#import <UIKit/UIKit.h>
#import "MutableCropView.h"
#import "Common.h"




@interface CropEditorViewController : UIViewController <UIActionSheetDelegate >
{
    UIImage * mutableImage;
    MutableCropView * cropView;
    UIActionSheet * actionSheet;

}



@property (nonatomic, weak) id delegate;

@property (nonatomic, retain) UIImage * mutableImage;
@property (nonatomic, retain) MutableCropView * cropView;
@property (nonatomic, retain) UIActionSheet * actionSheet;

//button support for navigation bar
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end  // interface end



@protocol CropViewControllerDelegate <NSObject>

- (void)cropViewController:(CropEditorViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage;
- (void)cropViewControllerDidCancel:(CropEditorViewController *)controller;

@end



