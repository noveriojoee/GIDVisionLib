//
//  GIDOcrProtocol.h
//  GIDVisionLib
//
//  Created by Noverio Joe on 10/01/19.
//  Copyright © 2019 gid. All rights reserved.
//

#ifndef GIDOcrProtocol_h
#define GIDOcrProtocol_h


#endif /* GIDOcrProtocol_h */

@protocol GIDOcrProtocol <NSObject>
@optional
-(void)onFailureWithMessage:(NSString*)message;

@required
-(void)onCompletedWithResult:(NSString*)capturedText image:(NSString*)imageBase64 viewController:(UIViewController*) ocrViewController;
-(void)onCancel;
@end
