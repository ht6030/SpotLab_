//
//  HTIndicatorBlockView.m
//  Memoris
//
//  Created by 高橋 弘 on 2014/06/28.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import "SLIndicatorBlockView.h"

@interface SLIndicatorBlockView()
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@end

@implementation SLIndicatorBlockView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite: 0.0 alpha: 0.8];
        self.clipsToBounds = YES;
        self.hidden = YES;
        self.layer.cornerRadius = 3;
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        [_indicator startAnimating];
        [self addSubview: _indicator];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite: 0.0 alpha: 0.8];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 3;
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        [_indicator startAnimating];
        [self addSubview: _indicator];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //self.frame = CGRectMake(0, 0, 200, 60);
    _indicator.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
}

@end
