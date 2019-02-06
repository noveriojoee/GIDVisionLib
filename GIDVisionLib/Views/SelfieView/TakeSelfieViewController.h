//
//  TakeSelfieViewController.h
//  GIDVisionLib
//
//  Created by Noverio Joe on 06/02/19.
//  Copyright © 2019 gid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GIDOcrProtocol.h"
#import "OCRViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TakeSelfieViewController : UIViewController
@property (weak, nonatomic) id<GIDOcrProtocol> delegate;
@property OCRViewModel* viewModel;
@end

NS_ASSUME_NONNULL_END
