//
//  OCRViewController.h
//  GIDVisionLib
//
//  Created by Noverio Joe on 07/01/19.
//  Copyright © 2019 gid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "OCRViewModel.h"
#import "GIDOcrProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCRViewController : UIViewController
@property (nonatomic,retain) AVCaptureSession *captureSession;
@property (nonatomic,retain) CALayer *customLayer;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic,retain) AVCaptureDeviceInput *captureInput;
@property (nonatomic,retain) AVCaptureVideoDataOutput *captureOutput;
@property (nonatomic,retain) AVCapturePhotoSettings *capturePhotoSetting;
@property (weak, nonatomic) IBOutlet UITextView *tvOcrResult;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIView *viewOverlay;
@property dispatch_queue_t captureSessionQueue;
@property OCRViewModel* viewModel;

@property (weak, nonatomic) id<GIDOcrProtocol> delegate;
@end

NS_ASSUME_NONNULL_END
