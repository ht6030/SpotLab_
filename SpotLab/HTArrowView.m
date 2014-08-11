//
//  HTArrowView.m
//  Memoris
//
//  Created by 高橋 弘 on 2014/06/26.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import "HTArrowView.h"

@implementation HTArrowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    // 塗りつぶす色を設定する。
    [[UIColor darkGrayColor] setFill];
    
    // 三角形のパスを書く　（３点でオープンパスにした。）
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    CGContextMoveToPoint(ctx, 0, height / 5 * 2);
    CGContextAddLineToPoint(ctx, width/2, 0);
    CGContextAddLineToPoint(ctx, width, height / 5 * 2);
    CGContextAddLineToPoint(ctx, width / 7 * 5, height / 5 * 2);
    CGContextAddLineToPoint(ctx, width / 7 * 5, height);
    CGContextAddLineToPoint(ctx, width / 7 * 2, height);
    CGContextAddLineToPoint(ctx, width / 7 * 2, height / 5 * 2);
    
    // 塗りつぶす
    CGContextFillPath(ctx);
}


@end
