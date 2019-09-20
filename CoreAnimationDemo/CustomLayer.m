//
//  CustomLayer.m
//  CoreAnimationDemo
//
//  Created by 贺文杰 on 2019/9/6.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import "CustomLayer.h"

@interface CustomLayer ()<CALayerDelegate>

@end

@implementation CustomLayer

- (void)displayLayer:(CALayer *)layer
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


@end
