//
//  OCRViewModel.h
//  GIDVisionLib
//
//  Created by Noverio Joe on 10/01/19.
//  Copyright © 2019 gid. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface OCRViewModel : NSObject
@property NSData* rawImage;
@property NSString* capturedText;
@property NSString* ocrMode;


-(instancetype)initWithOcrMode : (NSString*)ocrMode;
-(NSString*)extractCardInformation;
-(NSString*)getCapturedImageBase64;
@end

NS_ASSUME_NONNULL_END
