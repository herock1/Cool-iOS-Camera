//
//  CameraViewController.m
//  CameraWithAVFoundation
//
//  Created by Gabriel Alvarado on 4/16/14.
//  Copyright (c) 2014 Gabriel Alvarado. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraSessionView.h"

@interface CameraViewController () <CACameraSessionDelegate>

@property (nonatomic, strong) CameraSessionView *cameraView;

@end

@implementation CameraViewController
{
    CGFloat screenWidth,screenHeight;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
        screenWidth = screenRect.size.width;
        screenHeight = screenRect.size.height;
    
//    CAShapeLayer *rectLayer = [CAShapeLayer layer];
//    [rectLayer setPath:[[UIBezierPath bezierPathWithRect:CGRectMake(screenWidth/8, (screenHeight/9) * 3, (screenWidth/8) * 5, (screenHeight/9) * 4)] CGPath]];
//    [rectLayer setStrokeColor:[[UIColor redColor] CGColor]];
//    [rectLayer setFillColor:[[UIColor clearColor] CGColor]];
//    [[self.view layer] addSublayer:rectLayer];
    
}

- (IBAction)launchCamera:(id)sender {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CAShapeLayer *rectLayer = [CAShapeLayer layer];
    [rectLayer setPath:[[UIBezierPath bezierPathWithRect:CGRectMake(screenWidth/8, (screenHeight/9) * 3, (screenWidth/8) * 5, (screenHeight/9) * 4)] CGPath]];
    [rectLayer setStrokeColor:[[UIColor redColor] CGColor]];
    [rectLayer setFillColor:[[UIColor clearColor] CGColor]];
    
    //Set white status bar
    [self setNeedsStatusBarAppearanceUpdate];
    
    //Instantiate the camera view & assign its frame
    _cameraView = [[CameraSessionView alloc] initWithFrame:self.view.frame];
    
    //Set the camera view's delegate and add it as a subview
    _cameraView.delegate = self;
    
    //Apply animation effect to present the camera view
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.6];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[_cameraView layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    [[self.cameraView layer] addSublayer:rectLayer];

    [self.view addSubview:_cameraView];
    
    //____________________________Example Customization____________________________
    //[_cameraView setTopBarColor:[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha: 0.64]];
    //[_cameraView hideFlashButton]; //On iPad flash is not present, hence it wont appear.
    //[_cameraView hideCameraToggleButton];
    //[_cameraView hideDismissButton];
}

-(void)didCaptureImage:(UIImage *)image {
    NSLog(@"CAPTURED IMAGE");
    self.imageView.image = [self cropImage:image];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    [self.cameraView removeFromSuperview];
}

-(void)didCaptureImageWithData:(NSData *)imageData {
    NSLog(@"CAPTURED IMAGE DATA");
    //UIImage *image = [[UIImage alloc] initWithData:imageData];
    //UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    //[self.cameraView removeFromSuperview];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    //Show error alert if image could not be saved
    if (error) [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}

- (UIImage *) cropImage:(UIImage *)originalImage
{
    NSLog(@"original image orientation:%d",originalImage.imageOrientation);
    
    //calculate scale factor to go between cropframe and original image
    
    float ratiowidth,ratioheight,x,y,height,width;
    
    ratiowidth = originalImage.size.width/screenWidth;
    ratioheight = originalImage.size.height/(screenHeight-150);
    x= (screenWidth/2-100)*ratiowidth;
    y = 110.0*ratioheight;
    width = 200*ratiowidth;
    height = 300*ratioheight;
    
    
    //    float SF = originalImage.size.width / cropSize.width;
    
    //find the centre x,y coordinates of image
    float centreX = originalImage.size.width / 2;
    float centreY = originalImage.size.height / 2;
    
    //calculate crop parameters
    //    float cropX = centreX - ((cropSize.width / 2) * SF);
    //    float cropY = centreY - ((cropSize.height / 2) * SF);
    
    CGRect cropRect = CGRectMake(x,y,width,height);
    CGAffineTransform rectTransform;
    switch (originalImage.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), 0, -originalImage.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), -originalImage.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI), -originalImage.size.width, -originalImage.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    rectTransform = CGAffineTransformScale(rectTransform, originalImage.scale, originalImage.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectApplyAffineTransform(cropRect, rectTransform));
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:originalImage.scale orientation:originalImage.imageOrientation];
    CGImageRelease(imageRef);
    //return result;
    
    //Now want to scale down cropped image!
    //want to multiply frames by 2 to get retina resolution
    CGRect scaledImgRect = CGRectMake(0, 0, width,height);
    
    UIGraphicsBeginImageContextWithOptions(scaledImgRect.size, NO, [UIScreen mainScreen].scale);
    
    [result drawInRect:scaledImgRect];
    
    UIImage *scaledNewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledNewImage;
    
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
