//
//  OCRViewController.m
//  GIDVisionLib
//
//  Created by Noverio Joe on 07/01/19.
//  Copyright © 2019 gid. All rights reserved.
//

#import "OCRViewController.h"
#import "Utility.h"
#import "UIImage+Cropping.h"
#import <GoogleMobileVision/GoogleMobileVision.h>


@interface OCRViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>{
    BOOL isReadingImage;
}
@property Utility *util;
@property UIView* uiViewTextDetectionIndicatorOverlay;
@property CGRect uiViewTextDetectionIndicatorOverlayFrame;
@property CGRect overlayRect;
@property CGRect overlayRectBounds;
@property CGRect cameraViewBoundsSize;
@property CGRect originalViewFrame;
@property CGRect overlayTextViewFrame;

@property UIView *originalView;
@property UIView* overlayTextView;
@property float contanstPosition;

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic,strong) UIImage *imageToProcess;
@property (nonatomic, strong) GMVDetector *textDectector;
@property (atomic, strong) NSString* capturedText;
@property (weak, nonatomic) IBOutlet UIView *uiViewPasFoto;


@property int counter;
@property int radius;
@property int scanningTresshold;

@end

@implementation OCRViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.util = [Utility new];
    
    self.imageToProcess = nil;
    //noverio remark begin : to rotate object
    self.btnClose.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.viewOverlay.layer.borderColor = [UIColor blackColor].CGColor;
    self.viewOverlay.layer.cornerRadius = 10;
    self.viewOverlay.layer.borderWidth = 1;
    self.textDectector = [GMVDetector detectorOfType:GMVDetectorTypeText options:nil];
    self.counter = 0;
    self.radius = 10;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.overlayRect = self.viewOverlay.frame;
    self.overlayRectBounds = self.viewOverlay.bounds;
    self.originalView = self.view;
    self.cameraViewBoundsSize = self.cameraView.bounds;
    self.originalViewFrame = self.originalView.frame;
    self.uiViewPasFoto.layer.borderWidth = 1;
    self.uiViewPasFoto.layer.borderColor = [UIColor blackColor].CGColor;
    if ([self.viewModel.ocrMode isEqualToString:@"KTP"]){
        self.uiViewTextDetectionIndicatorOverlay = [self createReadedTextIndicator];
        self.uiViewTextDetectionIndicatorOverlayFrame = self.uiViewTextDetectionIndicatorOverlay.frame;
        self.contanstPosition = 15;
        self.uiViewPasFoto.hidden = NO;
        self.scanningTresshold = 10;
    }else{
        self.contanstPosition = 0;
        self.scanningTresshold = 50;
        self.uiViewPasFoto.hidden = YES;
    }
    [self.viewOverlay addSubview:self.uiViewTextDetectionIndicatorOverlay];
    [self initCapture];
}

-(UIView*)createReadedTextIndicator{
    UIView* result = [[UIView alloc] initWithFrame:CGRectMake(185, 97, 6, 160)];
    result.frame = CGRectMake(190, 60, 20, 200);
    result.layer.borderColor = [UIColor greenColor].CGColor;
    result.layer.borderWidth = 1;
    result.clipsToBounds = YES;
    
    return result;
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
        
        UIImage* rotatedImage = [UIImage imageWithCGImage:[originalImage CGImage]
                                                    scale:[originalImage scale]
                                              orientation: UIImageOrientationRight];
        
        UIImage* cropImageInScanArea = [rotatedImage cropRectangle:self.overlayRect inFrame:self.originalViewFrame.size];
        
        [self performRecognitionWithImage:cropImageInScanArea];
    }
}

#pragma recognision part

- (void)performRecognitionWithImage : (UIImage*)originalImage{
    NSArray<GMVTextBlockFeature *> *features = [self.textDectector featuresInImage:originalImage options:nil];
    
    NSString* readedText = @"";
    NSString* recognizedText = @"";
    for (GMVTextBlockFeature *textBlock in features) {
        // For each text block, iterate over each line.
        for (GMVTextLineFeature *textLine in textBlock.lines) {
            readedText = [readedText stringByAppendingString:textLine.value];
            readedText = [readedText stringByAppendingString:@" \n"];
            if (![[self.viewModel extractCardInformationFromString:textLine.value] isEqualToString:@"NOT_FOUND"]){
                [self drawRectacngleOverlayWithRect:textLine.bounds];
            }
        }
    }
    
    recognizedText = [self.viewModel extractCardInformationFromString:readedText];
    
    if ((self.overlayTextViewFrame.origin.x < self.uiViewTextDetectionIndicatorOverlayFrame.origin.x + self.radius  && self.overlayTextViewFrame.origin.x > self.uiViewTextDetectionIndicatorOverlayFrame.origin.x - self.radius  )
        && (self.overlayTextViewFrame.origin.y  < self.uiViewTextDetectionIndicatorOverlayFrame.origin.y + self.radius  && self.overlayTextViewFrame.origin.y > self.uiViewTextDetectionIndicatorOverlayFrame.origin.y - self.radius )){
        if (![recognizedText isEqualToString:@"NOT_FOUND"]){
            self.counter = self.counter + 1;
            if (self.counter >= self.scanningTresshold){
                //stop scanning.
                UIImage* rotatedImageUp = [UIImage imageWithCGImage:[originalImage CGImage]
                                                              scale:[originalImage scale]
                                                        orientation: UIImageOrientationUp];
                
                self.viewModel.rawImage = UIImageJPEGRepresentation(rotatedImageUp, 0.0);
                
                self.viewModel.capturedText = recognizedText;
                isReadingImage = true;
                NSString* stringBase64 = [self.viewModel.rawImage base64EncodedStringWithOptions:NSUTF8StringEncoding];
                [self.delegate onCompletedWithResult:self.viewModel.capturedText image:stringBase64 viewController:self];
            }else{
                //continue scanning
                isReadingImage = false;
            }
        }else{
            //continue scanning
            isReadingImage = false;
        }
    }else{
        //continue scanning
        isReadingImage = false;
    }
}

-(void)drawRectacngleOverlayWithRect:(CGRect)rectangle{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.overlayTextView != nil){
            [self.overlayTextView removeFromSuperview];
        }
        self.overlayTextView = [[UIView alloc] initWithFrame:rectangle];
        
        self.overlayTextViewFrame = CGRectMake(self.overlayRectBounds.size.width - (rectangle.origin.y - self.contanstPosition), self.overlayRectBounds.origin.y + rectangle.origin.x, rectangle.size.height, rectangle.size.width + 5);
        self.overlayTextView.frame = self.overlayTextViewFrame;
        
        self.overlayTextView.layer.borderColor = [UIColor blackColor].CGColor;
        self.overlayTextView.layer.borderWidth = 1;
        
        [self.viewOverlay addSubview:self.overlayTextView];
    });
}

- (IBAction)btnCloseClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
