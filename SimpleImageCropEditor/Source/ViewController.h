//
//  ViewController.h
//  SimpleImageCropEditor
//
//  Created by MobileSandbox1 on 1/9/14.
//  Copyright (c) 2014 MobileSandbox LLC. All rights reserved.
//
//  This is the Root container View.  In this case, simple app, this
//  will become the central runtime container for it.
//


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "CropEditorViewController.h"
#import "GrayScaleEditorViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Common.h"





@interface ViewController : UIViewController <UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate,
MFMailComposeViewControllerDelegate>

{
    
    IBOutlet UIBarButtonItem * photoEditButton;
    IBOutlet UIBarButtonItem * mailButton;
    IBOutlet UIBarButtonItem * cameraButton;
    IBOutlet UIImageView     * imageView;
    UIActivityIndicatorView  * updateProgressInd;
}


@property(nonatomic,weak) id<MFMailComposeViewControllerDelegate> mailComposeDelegate;

// Button support
@property (nonatomic, retain) IBOutlet UIBarButtonItem * mailButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * photoEditButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * cameraButton;

@property (nonatomic, retain) IBOutlet UIImageView     * imageView;

// iOS 2.0 and later
@property ( nonatomic, retain) UIActivityIndicatorView	*updateProgressInd;


- (IBAction) launchSystemCamera:(id)sender;
- (IBAction) launchSystemMail:(id)sender;
- (IBAction) editButtonActionSheet:(id)sender;


- (void) launchCropEditor;
- (void) launchSystemGrayScaleEditor;

- (void) showMailPicker;
- (void) displayComposerSheet;
- (void) mailComposeController:(MFMailComposeViewController*)controller
           didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;

-(void) startActivityInd;
-(void) stopActivityInd;


- (UIImage *)scaleAndRotateImage:(UIImage *)image;

@end
