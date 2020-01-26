//
//  TakeSignatureViewController.h
//  GIDVisionLib
//
//  Created by Noverio Joe on 21/04/19.
//  Copyright © 2019 gid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GIDOcrProtocol.h"
#import "OCRViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TakeSignatureViewController : UIViewController
@property (weak, nonatomic) id<GIDOcrProtocol> delegate;
@property OCRViewModel* viewModel;
@end

NS_ASSUME_NONNULL_END
