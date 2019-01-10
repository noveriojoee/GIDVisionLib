//
//  OCRViewModel.m
//  GIDVisionLib
//
//  Created by Noverio Joe on 10/01/19.
//  Copyright © 2019 gid. All rights reserved.
//

#import "OCRViewModel.h"
#import "Utility.h"


@interface OCRViewModel ()
@property Utility* util;
@end
@implementation OCRViewModel
-(instancetype)init {
    if ( self = [super init] ) {
        self.capturedText = @"";
        self.ocrMode = @"DEBIT_CARD";
        self.util = [Utility new];
    }
    return self;
}

-(instancetype)initWithOcrMode : (NSString*)ocrMode {
    if ( self = [super init] ) {
        self.capturedText = @"";
        self.ocrMode = ocrMode;
        self.util = [Utility new];
    }
    return self;
}


-(NSString*)extractCardInformation{
    NSString* result;
    if ([self.ocrMode isEqualToString:@"DEBIT_CARD"]){
        result = [self.util extractDebitCardNumber:self.capturedText];
    }else if([self.ocrMode isEqualToString:@"KTP"]){
        result = [self.util extractNIK:self.capturedText];
    }else if([self.ocrMode isEqualToString:@"NPWP"]){
        result = [self.util extractNPWP:self.capturedText];
    }else{
        result = @"NOT_FOUND";
    }
    return result;
}



@end
