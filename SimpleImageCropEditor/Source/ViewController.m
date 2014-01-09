//
//  ViewController.m
//  SimpleImageCropEditor
//
//  Created by MobileSandbox1 on 1/9/14.
//  Copyright (c) 2014 MobileSandbox LLC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()  //<CropEditorViewControllerDelegate>

@end


@implementation ViewController

@synthesize mailButton, cameraButton, photoEditButton, imageView, updateProgressInd;



#pragma mark -
#pragma mark View LifeCycle


- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
#if(PPTIE_Debug == 1)
    NSLog(@"ViewController::viewWillAppear");
#endif
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
#if(PPTIE_Debug == 1)
        NSLog(@"ViewController::CAMERA IS AVAILABLE");
#endif
        
        self.cameraButton.enabled = YES;
        self.mailButton.enabled = NO;
        self.photoEditButton.enabled = NO;
    }
    else
    {
#if(PPTIE_Debug == 1)
        NSLog(@"ViewController::CAMERA IS NOT AVAILABLE");
#endif
        
        self.cameraButton.enabled = NO;
        self.mailButton.enabled = NO;
        self.photoEditButton.enabled = NO;
        
        NSString *message = [[NSString alloc] initWithFormat:@"There is a problem accessing the camera or your device does not have a camera. Maybe shutdown the device and restart the hardware."];
        
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Camera?"
                              message:message delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [alert show];
        
    }
    
}




- (void)viewDidUnload
{
    
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"start_activity_ind" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"stop_activity_ind" object:nil];
    
    self.cameraButton = nil;
    self.mailButton = nil;
    self.photoEditButton = nil;
    
    [super viewDidUnload];
    
    
}




- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [NSRunLoop currentRunLoop];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startActivityInd)
                                                 name:@"start_activity_ind"
                                               object:self];
    
    
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"start_activity_ind"
                                                                                          object:self]
                                               postingStyle:NSPostASAP
                                               coalesceMask:
     (NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender)
                                                   forModes:nil];
    
    
    [NSRunLoop currentRunLoop];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopActivityInd) name:@"stop_activity_ind" object:self];
    
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"stop_activity_ind"
                                                                                          object:self] postingStyle:NSPostASAP coalesceMask:(NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender)  forModes:nil];
    
    
    
    CGRect frame = CGRectMake(140.0f, 217.0f, 200.0f, 200.0f);
    updateProgressInd = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    self.updateProgressInd.hidesWhenStopped = YES;
    [updateProgressInd stopAnimating];
    updateProgressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    updateProgressInd.color = [UIColor redColor];
    [updateProgressInd sizeToFit];
    [self.view addSubview:updateProgressInd];
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark -  Button Support



- (IBAction)editButtonActionSheet:(id)sender
{
    
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Crop Photo Editor", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Gray Scale Editor", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    [actionSheet showFromToolbar:self.navigationController.toolbar];
    
}



- (IBAction) launchSystemCamera: (id)sender
{
    
    
    UIImagePickerController * imageController = [[UIImagePickerController alloc] init];
    imageController.delegate = self;
    imageController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    
    imageController.mediaTypes =  @[(NSString*)kUTTypeImage];
    imageController.allowsEditing = NO;
    imageController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    
    switch(imageController.interfaceOrientation )
    {
        case UIInterfaceOrientationPortrait:
#if(PPTIE_Debug == 1)
            NSLog(@"launchSystemCamera:imageController.interfaceOrientation == UIInterfaceOrientationPortrait");
#endif
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
#if(PPTIE_Debug == 1)
            NSLog(@"launchSystemCamera:imageController.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown");
#endif
            break;
        case UIInterfaceOrientationLandscapeLeft:
#if(PPTIE_Debug == 1)
            NSLog(@"launchSystemCamera:imageController.interfaceOrientation == UIInterfaceOrientationLandscapeLeft");
#endif
            break;
        case UIInterfaceOrientationLandscapeRight:
#if(PPTIE_Debug == 1)
            NSLog(@"launchSystemCamera:imageController.interfaceOrientation == UIInterfaceOrientationLandscapeRight");
#endif
            break;
        default:
#if(PPTIE_Debug == 1)
            NSLog(@"---------");
#endif
            break;
    }
    
    [self presentViewController:imageController animated:YES completion:NULL];
    
}




- (IBAction) launchSystemMail: (id)sender
{
#if(PPTIE_Debug == 1)
    NSLog(@"ViewController:launchSystemMail");
#endif
    
    
    [self showMailPicker];
    
}






- (void) launchCropEditor
{
#if(PPTIE_Debug == 1)
    NSLog(@"ViewController:launchCropEditor");
#endif
    
    
    //open the modal crop view editor - 1st init
    CropEditorViewController *controller = [[CropEditorViewController alloc] init];
    
    controller.delegate = self;
    
    controller.mutableImage = self.imageView.image;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:YES completion:NULL];
    
}





- (void) launchSystemGrayScaleEditor
{
#if(PPTIE_Debug == 1)
    NSLog(@"ViewController:launchSystemGrayScaleEditor");
#endif
    
    GrayScaleEditorViewController *grayScaleController = [[GrayScaleEditorViewController alloc] init];
    
    grayScaleController.grayScaleDelegate = self;
    grayScaleController.mutableImage = self.imageView;
    
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:grayScaleController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}






#pragma mark - Action Sheet Popup Delegate Selected Callback

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
#if(PPTIE_Debug == 1)
    NSLog(@"actionSheet:clickedButtonAtIndex");
#endif
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Crop Photo Editor", nil)])
    {
        [self launchCropEditor];
        
    }
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Gray Scale Editor", nil)])
    {
        [self launchSystemGrayScaleEditor];
    }
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Cancel", nil)])
    {
        // Do nothing -
#if(PPTIE_Debug == 1)
        NSLog(@"clickedButtonAtIndex:Cancel");
#endif
    }
}



#pragma mark - UIImagePickerController Delegate Callback

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
#if(PPTIE_Debug == 1)
    NSLog(@"ViewController::imagePickerController: didFinishPickingMediaWithInfo");
#endif
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"start_activity_ind" object:self];
    
    UIImage * rawImage = info[UIImagePickerControllerOriginalImage];
    
    UIImage * rotatedImage;
    switch( rawImage.imageOrientation )
    {
        case UIImageOrientationUp:
#if(PPTIE_Debug == 1)
            NSLog(@"rawImage(UIImageOrientationUp)");
#endif
            break;
            
        case UIImageOrientationLeft:
#if(PPTIE_Debug == 1)
            NSLog(@"rawImage(UIImageOrientationLeft)");
#endif
            break;
            
        case UIImageOrientationRight:
#if(PPTIE_Debug == 1)
            NSLog(@"rawImage(UIImageOrientationRight)");
#endif
            break;
            
        case UIImageOrientationDown:
#if(PPTIE_Debug == 1)
            NSLog(@"rawImage(UIImageOrientationDown)");
#endif
            break;
            
        default:
            
            break;
            
            
    }
    
    rotatedImage = [self scaleAndRotateImage:rawImage];
    
    //Basically dismiss the camera, completion block run as atomic/independent thread,
    //  and launch the
    [picker dismissViewControllerAnimated:YES completion:^{
        
        // Use the ARC setter functions to load the image
        self.imageView.image = rotatedImage;
        
        
#if(PPTIE_Debug == 1)
        NSLog(@"ViewController::imagePickerController: IMAGE LOADED");
#endif
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString * fileName = @"PTT";
        
        
        //NSString *filePath2 = [NSString stringWithFormat:@"%@/%@.jpg", documentsDirectory, fileName];
        NSString *filePath3 = [NSString stringWithFormat:@"%@/%@.png", documentsDirectory, fileName];
        
#if(PPTIE_Debug == 1)
        NSLog(@"%@", filePath2);
        NSLog(@"%@", filePath3);
#endif
        
        //NSData* imageDataJPEG = UIImageJPEGRepresentation(self.imageView.image, 1.0);
        // Removed from implimentation. Spec only request one image format be loaded in the
        // email.
        //[imageDataJPEG writeToFile:filePath2 atomically:YES];
        
        NSData* imageDataPNG = UIImagePNGRepresentation(self.imageView.image);
        [imageDataPNG writeToFile:filePath3 atomically:YES];
        
        self.cameraButton.enabled = YES;
        self.mailButton.enabled = YES;
        self.photoEditButton.enabled = YES;
        
        [self updateViewConstraints];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stop_activity_ind" object:self];
        
    }];
    
}



#pragma mark -  MFMailComposeViewController


-(void)showMailPicker
{
	// This sample can run on devices running iPhone OS 2.0 or later
	// The MFMailComposeViewController class is only available in iPhone OS 3.0 or later.
	// So, we must verify the existence of the above class and provide a workaround for devices running
	// earlier versions of the iPhone OS.
	// We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
	// We launch the Mail application on the device, otherwise.
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([MFMailComposeViewController canSendMail])
		{
			[self displayComposerSheet];
            
#if(PPTIE_Debug == 1)
            NSLog(@"Can Send Email");
#endif
        }
		else
		{
			//[self launchMailAppOnDevice];
#if(PPTIE_Debug == 1)
            NSLog(@"Cannot Send Email");
#endif
            
            NSString *message = [[NSString alloc] initWithFormat:@"Unable to send an email from this device. Please check to see if you have configured an email account."];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Email Account?"
                                  message:message delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            
            [alert show];
            
		}
	}
	else
	{
		//[self launchMailAppOnDevice];
	}
    
    
}



#pragma mark -
#pragma mark Utilities Functions/Methods


- (UIImage *)scaleAndRotateImage:(UIImage *)image
{
    
    int kMaxResolution = 640; // This will contraint the image on the iPhone
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    if (width > kMaxResolution || height > kMaxResolution)
    {
        
        
        CGFloat ratio = width/height;
        
        // This is where the magic occurs for the ratio
        // on the rotation
        if (ratio > 1)
        {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else
        {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
        
        
    }
    
    
    CGFloat scaleRatio = bounds.size.width / width;
    
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    
    CGFloat boundHeight;
    
    UIImageOrientation orient = image.imageOrientation;
    
    switch(orient)
    {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
            
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
            
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}





//Useful util function/method to get the Document directory path in a String
// BUZ  profiler did not pick it up.
-(NSString *) getDataPath
{
    NSArray * localPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [localPath objectAtIndex:0];
    
    return documentsDirectory;
}



#pragma mark -
#pragma mark Compose Mail Interface and Callbacks

// Displays an email composition interface inside the application. Populates all the Mail fields.
-(void)displayComposerSheet
{
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
    
    
	// Attach an image to the email
	NSString *documentsDirectory =  [self getDataPath];
    
    NSString * fileName = @"PTT";
    // NSString *filePath2 = [NSString stringWithFormat:@"%@/%@.jpg", documentsDirectory, fileName];
    NSString *filePath3 = [NSString stringWithFormat:@"%@/%@.png", documentsDirectory, fileName];
    
#if(PPTIE_Debug == 1)
    NSLog(@"%@", filePath2);
    NSLog(@"%@", filePath3);
#endif
    
    NSData *myData = [NSData dataWithContentsOfFile:filePath3];
	[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"PTT"];
    
    // Attach an image to the email
    //NSData *myData2 = [NSData dataWithContentsOfFile:filePath2];
    // not specified, but code remains for later.
    //[picker addAttachmentData:myData2 mimeType:@"image/jpg" fileName:@"PTT"];
    
    [self presentViewController:picker animated:YES completion:nil];
#if(PPTIE_Debug == 1)
    NSLog(@"displayComposerSheet");
#endif
}







- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
	//myMailMessage.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
#if(PPTIE_Debug == 1)
            NSLog(@"%u - MFMailComposeResultCancelled",result);
#endif
            break;
		case MFMailComposeResultSaved:
#if(PPTIE_Debug == 1)
            NSLog(@"%u - MFMailComposeResultSaved",result);
#endif
            break;
		case MFMailComposeResultSent:
#if(PPTIE_Debug == 1)
            NSLog(@"%u - MFMailComposeResultSent",result);
#endif
            break;
		default:
#if(PPTIE_Debug == 1)
            NSLog(@"%u - default",result);
#endif
            break;
	}
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.cameraButton.enabled = YES;
        self.mailButton.enabled = YES;
        self.photoEditButton.enabled = YES;
        
#if(PPTIE_Debug == 1)
        NSLog(@"ViewController:messageComposeViewController:dismissViewControllerAnimated");
#endif
    }];
	
}




#pragma mark -
#pragma mark  Crop Edit Protocol Implimentation

//for CropEditorViewControllerDelegate
- (void)cropViewController:(UIViewController *)controller didFinishCroppingImage:(UIImage *)alteredImage
{
    
    
    if(alteredImage == nil)
    {
        // pop up an modal view alert to let the user know there is a problem
        // do not set the image and return the function
        return;
    }
    
    self.imageView.image = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"start_activity_ind" object:self];
    
    [controller dismissViewControllerAnimated:YES completion:^{
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.image = alteredImage;
        
        self.cameraButton.enabled = YES;
        self.mailButton.enabled = YES;
        self.photoEditButton.enabled = YES;
        
        [self.view setNeedsDisplay];
        
#if(PPTIE_Debug == 1)
        NSLog(@"ViewController:: IMAGE LOADED");
#endif
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString * fileName = @"PTT";
        
        
        //NSString *filePath2 = [NSString stringWithFormat:@"%@/%@.jpg", documentsDirectory, fileName];
        NSString *filePath3 = [NSString stringWithFormat:@"%@/%@.png", documentsDirectory, fileName];
        
#if(PPTIE_Debug == 1)
        NSLog(@"%@", filePath2);
        NSLog(@"%@", filePath3);
#endif
        
        //NSData* imageDataJPEG = UIImageJPEGRepresentation(self.imageView.image, 1.0);
        //  Removed from implimentation.
        //  Not part of the Specification.
        //  [imageDataJPEG writeToFile:filePath2 atomically:YES];
        
        NSData* imageDataPNG = UIImagePNGRepresentation(self.imageView.image);
        [imageDataPNG writeToFile:filePath3 atomically:YES];
        
        self.cameraButton.enabled = YES;
        self.mailButton.enabled = YES;
        self.photoEditButton.enabled = YES;
        
        [self updateViewConstraints];
        
        [self.view setNeedsDisplay];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stop_activity_ind" object:self];
        
    }];
    
}




- (void)cropViewControllerDidCancel:(UIViewController *)controller
{
    
#if(PPTIE_Debug == 1)
    NSLog(@"ViewController:cropViewControllerDidCancel");
#endif
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
    self.cameraButton.enabled = YES;
    self.mailButton.enabled = YES;
    self.photoEditButton.enabled = YES;
    
}







#pragma mark -
#pragma mark  GrayScale Protocol Implimentation
- (void)grayScaleViewController:(UIViewController *)controller didFinishGrayScaleImageChange:(UIImage *)alteredImage
{
#if(PPTIE_Debug == 1)
    NSLog(@"ViewController:grayScaleViewController:didFinishGrayScaleImageChange");
#endif
    if(alteredImage == nil)
    {
        // pop up an modal view alert to let the user know there is a problem
        // do not set the image and return the function
        return;
        
    }
    self.imageView.image = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"start_activity_ind" object:self];
    
    [controller dismissViewControllerAnimated:YES completion:^{
        
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.image = alteredImage;
        
        self.cameraButton.enabled = YES;
        self.mailButton.enabled = YES;
        self.photoEditButton.enabled = YES;
        
        [self.view setNeedsDisplay];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString * fileName = @"PTT";
        
        
        //NSString *filePath2 = [NSString stringWithFormat:@"%@/%@.jpg", documentsDirectory, fileName];
        NSString *filePath3 = [NSString stringWithFormat:@"%@/%@.png", documentsDirectory, fileName];
        
#if(PPTIE_Debug == 1)
        NSLog(@"%@", filePath2);
        NSLog(@"%@", filePath3);
#endif
        
        //NSData* imageDataJPEG = UIImageJPEGRepresentation(self.imageView.image, 1.0);
        // Taken out of implimentation, but code remains.
        // Spec only requires one file
        //[imageDataJPEG writeToFile:filePath2 atomically:YES];
        
        NSData* imageDataPNG = UIImagePNGRepresentation(self.imageView.image);
        [imageDataPNG writeToFile:filePath3 atomically:YES];
        
        self.cameraButton.enabled = YES;
        self.mailButton.enabled = YES;
        self.photoEditButton.enabled = YES;
        
        [self updateViewConstraints];
        
        [self.view setNeedsDisplay];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stop_activity_ind" object:self];
        
    }];
    
}




- (void)grayScaleViewControllerDidCancel:(UIViewController *)controller
{
#if(PPTIE_Debug == 1)
    NSLog(@"ViewController:grayScaleViewControllerDidCancel");
#endif
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
    self.cameraButton.enabled = YES;
    self.mailButton.enabled = YES;
    self.photoEditButton.enabled = YES;
    
}


#pragma mark -
#pragma mark Activity Indicator Support

-(void) startActivityInd
{
    
    [self.updateProgressInd startAnimating];
#if(PPTIE_Debug == 1)
    NSLog(@"[self.updateProgressInd startAnimating] ");
#endif
}




-(void) stopActivityInd
{
    
    int i = 0;
    
    while (i<1)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.250]];
        i++;
        
        [self.updateProgressInd stopAnimating];
#if(PPTIE_Debug == 1)
        NSLog(@"[self.updateProgressInd stopAnimating] ");
#endif
    }
}




@end
