//
//  SelfieCardFrame.m
//  GIDVisionLib
//
//  Created by Noverio Joe on 06/02/19.
//  Copyright © 2019 gid. All rights reserved.
//

#import "SelfieCardFrame.h"

@implementation SelfieCardFrame


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = true;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = UIColor.whiteColor.CGColor;
}


@end
