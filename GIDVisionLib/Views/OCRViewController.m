//
//  OCRViewController.m
//  GIDVisionLib
//
//  Created by Noverio Joe on 07/01/19.
//  Copyright © 2019 gid. All rights reserved.
//

#import "OCRViewController.h"
#import <GoogleMobileVision/GoogleMobileVision.h>

@interface OCRViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>{
    BOOL isReadingImage;
    CGRect overlayRect;
}
@property Utility *util;

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic,strong) UIImage *imageToProcess;
@property (nonatomic, strong) GMVDetector *textDectector;
@property UIView *originalView;
@end

@implementation OCRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.util = [Utility new];
    
    self.imageToProcess = nil;
    //noverio remark begin : to rotate object
    //    self.textResult.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.viewOverlay.layer.borderColor = [UIColor blackColor].CGColor;
    self.viewOverlay.layer.borderWidth = 1;
    self.textDectector = [GMVDetector detectorOfType:GMVDetectorTypeText options:nil];
    
    [self initCapture];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    overlayRect = self.viewOverlay.frame;
    self.originalView = self.view;
}

- (void)initCapture {
    NSError *error = nil;
    
    // Create the session
    self.captureSession = [[AVCaptureSession alloc] init];
    
    // Configure the session to produce lower resolution video frames, if your
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice
                               defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (!input) {
        // Handling the error appropriately.
    }
    [self.captureSession addInput:input];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [self.captureSession addOutput:output];
    
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    
    // Specify the pixel format
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    // Setup preview layer
    CGRect previewLayerRect        = self.cameraView.layer.bounds;
    self.previewLayer                = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.videoGravity    = self.previewLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame            = previewLayerRect;
    self.previewLayer.position        = CGPointMake(CGRectGetMidX(previewLayerRect), CGRectGetMidY(previewLayerRect));
    
    [self.cameraView.layer addSublayer:self.previewLayer];
    
    [self.captureSession startRunning];
}

#pragma mark - AVCapturePhotoCaptureDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    
    
    if (isReadingImage == false){
        isReadingImage = true;
        UIImage *originalImage = [self.util imageFromSampleBuffer:sampleBuffer];
        UIImage *scaledImage = [self.util resizeImage:originalImage];
        
        UIImage *cropImageInScanArea = [self.util cropImageToTheScanAreaOnly:overlayRect originalView:self.originalView forImage:scaledImage];
        
        self.imageToProcess = [UIImage imageWithCGImage:[cropImageInScanArea CGImage]
                                                  scale:[cropImageInScanArea scale]
                                            orientation: UIImageOrientationRight];
        
        [self performRecognitionWithImage:self.imageToProcess];
    }
}

#pragma recognision part

- (void)performRecognitionWithImage : (UIImage*)originalImage{
    NSArray<GMVTextBlockFeature *> *features = [self.textDectector featuresInImage:originalImage options:nil];
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        //Run UI Updates
        NSLog(@"Noverio Debug begin start here ");
        self.tvOcrResult.text = @"";
        for (GMVTextBlockFeature *textBlock in features) {
            NSLog(@"Text Block: %@", NSStringFromCGRect(textBlock.bounds));
            NSLog(@"lang: %@ value: %@", textBlock.language, textBlock.value);
            
            // For each text block, iterate over each line.
            for (GMVTextLineFeature *textLine in textBlock.lines) {
                NSLog(@"Text Line: %@", NSStringFromCGRect(textLine.bounds));
                NSLog(@"lang: %@ value: %@", textLine.language, textLine.value);
                self.tvOcrResult.text = [self.tvOcrResult.text stringByAppendingString:textLine.value];
                self.tvOcrResult.text = [self.tvOcrResult.text stringByAppendingString:@"\n"];
            }
        }
        NSLog(@"Noverio Debug end here ");
    });
    
    
    isReadingImage = false;
}


- (IBAction)btnCloseClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
