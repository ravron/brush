//
//  BRRadarView.m
//  Brush
//
//  Created by Riley Avron on 2/8/14.
//  Copyright (c) 2014 Riley Avron. All rights reserved.
//

#import "BRRadarView.h"

@interface BRRadarView ()

@property (strong, nonatomic) BRRadarBackgroundView *backgroundView;

@end

@implementation BRRadarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert(frame.size.height == frame.size.width, @"BRRadarView must be instantiated with a square frame!");
        
        CGRect bgRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _backgroundView = [[BRRadarBackgroundView alloc] initWithFrame:bgRect];
//        [self setBackgroundColor:[UIColor redColor]];
        [self addSubview:_backgroundView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
