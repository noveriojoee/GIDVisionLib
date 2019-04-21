//
//  TakeSignatureViewController.m
//  GIDVisionLib
//
//  Created by Noverio Joe on 21/04/19.
//  Copyright © 2019 gid. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "TakeSignatureViewController.h"
#import "Utility.h"

@interface TakeSignatureViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property Utility *util;
@property (nonatomic,retain) AVCaptureSession *captureSession;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic,retain) CALayer *customLayer;
@property (nonatomic,retain) AVCaptureDeviceInput *captureInput;
@property (nonatomic,retain) AVCaptureVideoDataOutput *captureOutput;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property dispatch_queue_t captureSessionQueue;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property UIImage *capturedImage;
@end

@implementation TakeSignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.util = [Utility new];
    [self initCapture];
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
    AVCaptureDevice *device = [self frontCamera];
    
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
    
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    self.capturedImage = [self.util imageFromSampleBuffer:sampleBuffer];
}


- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            return device;
        }
    }
    return nil;
}

- (IBAction)btnClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnTakePicture:(id)sender {
    [self.captureSession stopRunning];
    self.viewModel.rawImage = UIImageJPEGRepresentation(self.capturedImage, 0.0);
    NSString* stringBase64 = [self.viewModel.rawImage base64EncodedStringWithOptions:NSUTF8StringEncoding];
    [self.delegate onCompletedWithResult:self.viewModel.ocrMode image:stringBase64 viewController:self];
}




@end
