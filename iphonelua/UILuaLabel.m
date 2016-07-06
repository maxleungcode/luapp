//
//  UILuaLabel.m
//  iphonelua
//
//  Created by maxleung on 22/6/16.
//  Copyright © 2016 maxleung. All rights reserved.
//

#import "UILuaLabel.h"

@implementation UILuaLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)didAddSubview:(UIView *)subview{
    NSLog(@"load did");
}

-(void)dealloc{
    NSLog(@"OC dealloc ");
}

@end
