//
//  CropEditorViewController.m
//  SimpleImageCropEditor
//
//  Created by MobileSandbox1 on 1/9/14.
//  Copyright (c) 2014 MobileSandbox LLC. All rights reserved.

#import "MutableCropView.h"
#import "CropEditorViewController.h"


@interface CropEditorViewController ()


@end



@implementation CropEditorViewController


@synthesize delegate;
@synthesize mutableImage;
@synthesize cropView;
@synthesize actionSheet;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)loadView
{
    
    #if(PPTIE_Debug == 1 || CEVC_Debug == 1)
    NSLog(@"    CropEditorViewController::loadView");
    #endif
    
    UIView *contentView = [[UIView alloc] init];//create content container view
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
    
    
    // Now build the view that can be cropped and load it into the container!
    self.cropView = [[MutableCropView alloc] initWithFrame:contentView.bounds];
    
    [contentView addSubview:self.cropView];

    
}


- (void)viewDidLoad
{
    #if(PPTIE_Debug == 1 || CEVC_Debug == 1)
    NSLog(@"    CropEditorViewController::viewDidLoad");
    #endif
    
    [super viewDidLoad];

    // This changes the bounds of the navigation Controller view
    // to be below the Navigation Bar
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //create a cancel and done button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self
                                             action:@selector(cancel:)];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                              target:self
                                              action:@selector(done:)];
    
    self.navigationController.toolbarHidden = YES;
    
    
     self.cropView.image = self.mutableImage;
    
}







- (void)viewDidAppear:(BOOL)animated
{
    
    #if(PPTIE_Debug == 1 || CEVC_Debug == 1)
    NSLog(@"    CropEditorViewController::viewDidAppear");
    #endif
    
    
    [super viewDidAppear:animated];
    
    [self becomeFirstResponder];

}




//Does not get called because of the project setup files overrides. However leave it due to being
// part of the view lifecycle.

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}



- (IBAction)cancel:(id)sender
{
    #if(PPTIE_Debug == 1 || CEVC_Debug == 1)
    NSLog(@" CropEditorViewController:cancel");
    #endif
    
    if ([self.delegate respondsToSelector:@selector(cropViewControllerDidCancel:)])
    {
        [self.delegate cropViewControllerDidCancel:self];
    }
    
}


- (IBAction)done:(id)sender
{
    #if(PPTIE_Debug == 1 || CEVC_Debug == 1)
    NSLog(@"    CropEditorViewController::done");
    #endif
    
    if ([self.delegate respondsToSelector:@selector(cropViewController:didFinishCroppingImage:)])
    {
        [self.delegate cropViewController:self didFinishCroppingImage:self.cropView.croppedImage];
    }
    
}





@end

