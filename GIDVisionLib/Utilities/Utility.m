//
//  Utility.m
//  cardreader
//
//  Created by Noverio Joe on 07/05/18.
//  Copyright © 2018 ocbc. All rights reserved.
//

#import "Utility.h"

@implementation Utility


-(UIImage *)resizeImage:(UIImage *)image{
    //resize to 130x130 as showing at UI
    CGRect rect;
    if (image.size.width > image.size.height) {
        float ratio = image.size.height/image.size.width;
        rect = CGRectMake(0, 0, 600, 600 *ratio);
    }else{
        float ratio = image.size.width/image.size.height;
        rect = CGRectMake(0, 0, 600 * ratio, 600);
    }
    UIGraphicsBeginImageContext( rect.size );
    [image drawInRect:rect];
    UIImage *currentPicture = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImageJPEGRepresentation(currentPicture, 1.0);
    UIImage *finalImage=[UIImage imageWithData:imageData];
    return finalImage;
}

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    // Release the Quartz image
    CGImageRelease(quartzImage);
    return image;
}

- (UIImage *) cropImageToTheScanAreaOnly:(CGRect)scanAreaFrame originalView : (CGRect)viewFrame forImage:(UIImage *)image
{
    //get value in % from main view then convert capture frame with relation to image size
    float topMargin = scanAreaFrame.origin.y/viewFrame.size.height;
    float bottomMargin = ((scanAreaFrame.origin.y + scanAreaFrame.size.height)-viewFrame.size.height)/viewFrame.size.height;
    float leftMargin = scanAreaFrame.origin.x/viewFrame.size.width;
    float rightMargin = ((scanAreaFrame.origin.x+scanAreaFrame.size.width)-viewFrame.size.width)/viewFrame.size.width;
    float newLeft = image.size.width * leftMargin;
    float newRight = image.size.width * rightMargin;
    float newTop = image.size.height * topMargin;
    float newBottom = image.size.height *bottomMargin;
    float newWidth = image.size.width - newLeft - newRight;
    float newHeight = image.size.height - newTop - newBottom;
    
    CGRect newFrame = CGRectMake(newLeft, newTop, newWidth, newHeight);
    
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], newFrame);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

-(NSString *)extractWithRegex:(NSString *)regexString result:(NSString *)ScanResult{
    // track regex error
    NSError *error = NULL;
    
    // create regular expression
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:&error];
    
    // make sure there is no error
    if (!error) {
        
        // get all matches for regex
        NSArray *matches = [regex matchesInString:[ScanResult uppercaseString] options:0 range:NSMakeRange(0, ScanResult.length)];
        
        if (matches.count > 0) {
            // loop through regex matches
            for (NSTextCheckingResult *match in matches) {
                
                // get the current text
                NSString *matchText = [ScanResult substringWithRange:match.range];
                return matchText;
            }
        }
        
    }
    return @"";
}

#pragma extraction NPWP Number
-(NSString*) extractNIK:(NSString *)scanResult{
    NSString *nikNumber = @"NOT_FOUND";
    NSString *regexEKtpNIK = @"[0-9]{16}";
    NSString *regexReturn = [self extractWithRegex:regexEKtpNIK result:scanResult];
    if (regexReturn.length == 16){
        nikNumber = regexReturn;
    }
    return nikNumber;
}

#pragma extraction NPWP Number
-(NSString *)extractNPWP:(NSString *)ScanResult{
    NSString *NPWP = @"NOT_FOUND";
    
    NSString *REGEX_NPWP = @"[0-9]{2}[.][0-9]{3}[.][0-9]{3}[.][0-9][-][0-9]{3}[.][0-9]{3}";
    
    NSString *REGEX_NPWP1 = @"[0-9]{2}[.][0-9]{3}[.][0-9]{3}[.][0-9][.][0-9]{3}[.][0-9]{3}";
    
    NSString *regexReturn = [self extractWithRegex:REGEX_NPWP result:ScanResult];
    NSString *regextReturn1 = [self extractWithRegex:REGEX_NPWP1 result:ScanResult];
    if (regexReturn.length == 20) {
        NPWP = regexReturn;
    }
    if (regextReturn1.length == 20){
        NPWP = regextReturn1;
    }
    return NPWP;
}

#pragma extraction Card Number
-(NSString *)extractDebitCardNumber:(NSString *)ScanResult{
    NSString *debitCard = @"NOT_FOUND";
    
    NSString *REGEX_DEBITCARD = @"[0-9]{4}[ ][0-9]{4}[ ][0-9]{4}[ ][0-9]{4}";
    NSString *regexReturn = [self extractWithRegex:REGEX_DEBITCARD result:ScanResult];
    if (regexReturn.length == 19) {
        debitCard = regexReturn;
    }
    return debitCard;
}

@end
