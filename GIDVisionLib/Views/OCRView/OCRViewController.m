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
@property CGPoint uiViewTextDetectionIndicatorOverlayCenterPoint;
@property CGRect overlayRect;
@property CGRect overlayRectBounds;
@property CGRect cameraViewBoundsSize;
@property CGRect originalViewFrame;
@property CGRect overlayTextViewFrame;

@property UIView *originalView;
@property UIView *overlayTextView;
@property CGPoint overlayTextViewCenterPoint;
@property float contanstPosition;

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic,strong) UIImage *imageToProcess;
@property (nonatomic, strong) GMVDetector *textDectector;
@property (atomic, strong) NSString* capturedText;
@property (weak, nonatomic) IBOutlet UIView *uiViewPasFoto;
@property (weak, nonatomic) IBOutlet UILabel *lblKeterangan;

@property int counterFounded;
@property int scanningCounter;
@property int radius;
@property int scanningTresshold;
@property int scanningMaxTresshold;
@end

@implementation OCRViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.util = [Utility new];
    
    self.imageToProcess = nil;
    //noverio remark begin : to rotate object
    self.btnClose.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.lblKeterangan.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.viewOverlay.layer.borderColor = [UIColor blackColor].CGColor;
    self.viewOverlay.layer.cornerRadius = 10;
    self.viewOverlay.layer.borderWidth = 1;
    self.textDectector = [GMVDetector detectorOfType:GMVDetectorTypeText options:nil];
    self.counterFounded = 0;
    self.scanningCounter = 0;
    self.radius = 100;
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
        //remove nik rectangle begin
        self.uiViewTextDetectionIndicatorOverlay = [self createReadedTextIndicator];
        self.uiViewTextDetectionIndicatorOverlayFrame = self.uiViewTextDetectionIndicatorOverlay.frame;
        self.uiViewTextDetectionIndicatorOverlayCenterPoint = self.uiViewTextDetectionIndicatorOverlay.center;
        //remove nik rectangle end
        self.contanstPosition = 0;
        self.uiViewPasFoto.hidden = NO;
        self.scanningTresshold = self.valueScanningTresshold; //3
    }else{
        self.contanstPosition = 0;
        self.scanningTresshold = self.valueScanningTresshold;//15;
        self.uiViewPasFoto.hidden = YES;
    }
    self.scanningMaxTresshold = self.valueScanningMaxTresshold;//250;
    [self.viewOverlay addSubview:self.uiViewTextDetectionIndicatorOverlay];
    [self initCapture];
}

-(UIView*)createReadedTextIndicator{
    UIView* result = [[UIView alloc] initWithFrame:CGRectMake(185, 97, 6, 160)];
    result.frame = CGRectMake(190, 90, 20, 180);
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
        
//        UIImage* rotatedImage = [UIImage imageWithCGImage:[originalImage CGImage]
//                                                    scale:[originalImage scale]
//                                              orientation: UIImageOrientationRight];
        

        UIImage* cropImageInScanArea = [originalImage cropRectangle:CGRectMake(self.overlayRect.origin.y, self.originalViewFrame.size.width - (self.overlayRect.size.width + self.overlayRect.origin.x), self.overlayRect.size.height, self.overlayRect.size.width) inFrame:CGSizeMake(self.originalViewFrame.size.height, self.originalViewFrame.size.width)];
        
        [self performRecognitionWithImage:originalImage readedIMage:cropImageInScanArea];
    }
}

#pragma recognision part

- (void)performRecognitionWithImage : (UIImage*)originalImage readedIMage : (UIImage*)forReadImage{
    NSArray<GMVTextBlockFeature *> *features = [self.textDectector featuresInImage:forReadImage options:nil];
    
    NSString* readedText = @"";
    NSString* recognizedText = @"";
    for (GMVTextBlockFeature *textBlock in features) {
        // For each text block, iterate over each line.
        for (GMVTextLineFeature *textLine in textBlock.lines) {
            readedText = [self.viewModel extractCardInformationFromString:textLine.value];
            if (![readedText isEqualToString:@"NOT_FOUND"]){
                self.counterFounded = self.counterFounded + 1;
                recognizedText = readedText;
                [self drawRectacngleOverlayWithRect:textLine.bounds];
            }
        }
    }
    self.scanningCounter = self.scanningCounter + 1;
    
    if ([self.viewModel.ocrMode isEqualToString:@"KTP"] && self.counterFounded >= self.scanningTresshold && [self isThisArea:self.overlayTextViewCenterPoint containInThisArea:self.uiViewTextDetectionIndicatorOverlayCenterPoint]){
        //  ======== EKTP Mode ========
        //captured text
        self.viewModel.capturedText = recognizedText;
        //stop scanning.
        
        self.viewModel.rawImage = UIImageJPEGRepresentation(originalImage, 0.0);
        
        isReadingImage = true;

        NSString* stringBase64 = [self.viewModel.rawImage base64EncodedStringWithOptions:NSUTF8StringEncoding];
        [self.delegate onCompletedWithResult:self.viewModel.capturedText image:stringBase64 viewController:self];
        
    }else if((![self.viewModel.ocrMode isEqualToString:@"KTP"]) && self.counterFounded >= self.scanningTresshold){
        // ======== NPWP Mode  ========
        //captured text
        self.viewModel.capturedText = recognizedText;
        //stop scanning.
        
        self.viewModel.rawImage = UIImageJPEGRepresentation(originalImage, 0.0);
        
        isReadingImage = true;
        
        NSString* stringBase64 = [self.viewModel.rawImage base64EncodedStringWithOptions:NSUTF8StringEncoding];
        [self.delegate onCompletedWithResult:self.viewModel.capturedText image:stringBase64 viewController:self];
        
    }else if(self.scanningCounter > self.scanningMaxTresshold){
        isReadingImage = true;

        self.viewModel.rawImage = UIImageJPEGRepresentation(originalImage, 0.0);
        NSString* stringBase64 = [self.viewModel.rawImage base64EncodedStringWithOptions:NSUTF8StringEncoding];
        [self.delegate onCompletedWithResult:@"CANNOT_READ_IMAGE" image:stringBase64 viewController:self];

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
        self.overlayTextViewCenterPoint = self.overlayTextView.center;
        [self.viewOverlay addSubview:self.overlayTextView];
    });
}

-(BOOL)isThisArea : (CGPoint)targetArea containInThisArea:(CGPoint)scopeArea{
    if ((targetArea.x < scopeArea.x + self.radius  && targetArea.x > scopeArea.x - self.radius  )
        && (targetArea.y  < scopeArea.y + self.radius  && targetArea.y > scopeArea.y - self.radius )){
        return YES;
    }else{
        return false;
    }
}

- (IBAction)btnCloseClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
