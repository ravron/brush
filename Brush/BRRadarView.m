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
@property (strong, nonatomic) BRRadarPulseView *pulseView;

@end

@implementation BRRadarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert(frame.size.height == frame.size.width, @"BRRadarView must be instantiated with a square frame!");
        
        CGRect subviewRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _backgroundView = [[BRRadarBackgroundView alloc] initWithFrame:subviewRect];
        [self addSubview:_backgroundView];
        
        _pulseView = [[BRRadarPulseView alloc] initWithFrame:subviewRect];
        [self addSubview:_pulseView];
    }
    return self;
}

- (void)setAnimating:(BOOL)animating
{
    if (_animating == animating)
        return;
    
    if (_animating == NO && animating == YES) {
        _animating = YES;
        [[self pulseView] setAnimating:YES];
    } else if (_animating == YES && animating == NO) {
        _animating = NO;
        [[self pulseView] setAnimating:NO];
    }
}

- (void)radarPulseViewFinishedAnimation
{
    
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
