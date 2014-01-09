//
//  GrayScaleEditorViewController.m
//  SimpleImageCropEditor
//
//  Created by MobileSandbox1 on 1/9/14.
//  Copyright (c) 2014 MobileSandbox LLC. All rights reserved.

#import "GrayScaleEditorViewController.h"

@interface GrayScaleEditorViewController ()

@end



@implementation GrayScaleEditorViewController


@synthesize grayScaleDelegate;
@synthesize grayScaleImage;
@synthesize mutableImage;
@synthesize grayScaleImageView;
@synthesize containerView;


#pragma mark - View Cycle


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    
    return self;

}




- (UIImage *)  scaleToSize:(CGSize)targetSize
{
    
    
    // take the current image size.
    UIImage *sourceImage = self.mutableImage.image;
    UIImage *newImage = nil;

    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    // target size
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    // scaled sizes
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    // where the image will start to be installed
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
        {
            scaleFactor = widthFactor;
        }
        else
        {
            scaleFactor = heightFactor;
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image

        if (widthFactor < heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor > heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }

 
    }
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth- 5.0f;
    thumbnailRect.size.height = scaledHeight- 5.0f;
    
    CGSize localSize = CGSizeMake( scaledWidth, scaledHeight);
    
    UIGraphicsBeginImageContext(localSize);
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage ;

}




- (void) loadView
{
    
    self.containerView =  [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.containerView.backgroundColor = [UIColor whiteColor];
    
    CGSize aSize = CGSizeMake((self.containerView.bounds.size.width * 0.90f),
                              (self.containerView.bounds.size.height * 0.85f));

    CGPoint aPoint = CGPointMake(((self.containerView.bounds.size.width - aSize.width)/2.0f),
                                 ((self.containerView.bounds.size.height - aSize.height)/2.0f)+40.0f );
    
    CGRect aRect = CGRectMake(aPoint.x, aPoint.y, aSize.width, aSize.height);
    
    UIImageView * myView = [[UIImageView alloc] initWithFrame:aRect];
    myView.backgroundColor = [UIColor whiteColor];

    UIImage * img = [self scaleToSize: aSize ];
    
    self.grayScaleImageView = [[GrayScaleViewLayer alloc] initWithFrame:CGRectMake( aPoint.x,
                          ((myView.bounds.size.height/2.0f)-(img.size.height/2.0f))+aPoint.y,
                                                                              img.size.width,
                                                                             img.size.height) ];
    
    self.grayScaleImageView.backgroundImage = [self convertImageToGrayScale:mutableImage.image];
    
    [self.containerView addSubview:myView];
    [self.containerView addSubview:self.grayScaleImageView];
    
    self.view = self.containerView;
}



- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
    #if(PPTIE_Debug == 1)
    NSLog(@"    GrayScaleEditorViewController::viewDidLoad");
    #endif
    
    
    //create a cancel and done button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self
                                             action:@selector(cancel)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                              target:self
                                              action:@selector(accept)];
    
    self.title = @"Save?";
    
    self.navigationController.toolbarHidden = YES;

}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





- (void) cancel
{
    
    #if(PPTIE_Debug == 1)
    NSLog(@" GrayScaleEditorViewController:cancel");
    #endif
    if ([self.grayScaleDelegate
         respondsToSelector:@selector(grayScaleViewControllerDidCancel:)])
    {
        [self.grayScaleDelegate grayScaleViewControllerDidCancel:self];
    }
}




- (void) accept
{
    #if(PPTIE_Debug == 1)
    NSLog(@"    CropEditorViewController::done");
    #endif
    //Check to see if the prototype connection is available first.
    //  Then send the Root View Controller the new converted image.
    //
    if ([self.grayScaleDelegate respondsToSelector:@selector(grayScaleViewController:didFinishGrayScaleImageChange:)])
    {
        [self.grayScaleDelegate grayScaleViewController:self didFinishGrayScaleImageChange:self.grayScaleImageView.backgroundImage];
    }

    
}




- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    
    
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGBitmapByteOrderDefault );
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}


@end
