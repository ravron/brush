//
//  BRRadarPulseView.m
//  Brush
//
//  Created by Riley Avron on 2/8/14.
//  Copyright (c) 2014 Riley Avron. All rights reserved.
//

#import "BRRadarPulseView.h"



@interface BRRadarPulseView ()
{
    CGFloat animationDuration;
    CGFloat fractionOfDurationDelay;
    CGFloat lineWidth;
    CGFloat sideLen, minX, midX, maxX, minY, midY, maxY;
    UIColor *strokeColor;
}
@property BOOL newPulse;
@property (strong, nonatomic) CAShapeLayer *shapeLayer;
@property (strong, nonatomic) CAAnimationGroup *animationGroup;
@end

@implementation BRRadarPulseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert(frame.size.height == frame.size.width, @"BRRadarPulseView must be instantiated with a square frame!");
        // constants
        animationDuration = 2.25;
        fractionOfDurationDelay = .35;
        lineWidth = 6;
        
        sideLen = frame.size.height;
        minX = minY = 0;
        midX = midY = CGRectGetMidX(frame);
        maxX = maxY = CGRectGetMaxX(frame);
        strokeColor = [UIColor greenColor];
        
        // inits
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.strokeColor = [[UIColor clearColor] CGColor];
        _shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        _shapeLayer.lineWidth = lineWidth;
        [[self layer] addSublayer:_shapeLayer];
    }
    return self;
}

- (CAAnimationGroup *)animationGroup
{
    
    CGRect initialPulseRect = CGRectMake(midX - lineWidth / 2,
                                         midY - lineWidth / 2,
                                         lineWidth, lineWidth);
    CGRect finalPulseRect = CGRectMake(minX + lineWidth / 2,
                                       minY + lineWidth / 2,
                                       sideLen - lineWidth,
                                       sideLen - lineWidth);
    UIBezierPath *initialUIPath = [UIBezierPath bezierPathWithOvalInRect:initialPulseRect];
    UIBezierPath *finalUIPath = [UIBezierPath bezierPathWithOvalInRect:finalPulseRect];
    
    _animationGroup = [CAAnimationGroup animation];
    _animationGroup.duration = animationDuration * (1 + fractionOfDurationDelay);
    _animationGroup.delegate = self;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.duration = animationDuration;
    pathAnimation.fromValue = (__bridge id)([initialUIPath CGPath]);
    pathAnimation.toValue = (__bridge id)[finalUIPath CGPath];
    
    CABasicAnimation *strokeColorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
    strokeColorAnimation.duration = animationDuration;
    strokeColorAnimation.fromValue = (__bridge id)[strokeColor CGColor];
    strokeColorAnimation.toValue = (__bridge id)[[UIColor clearColor] CGColor];
    
    _animationGroup.animations = @[strokeColorAnimation, pathAnimation];
    return _animationGroup;
}

- (void)setAnimating:(BOOL)animating
{
    if (animating == _animating)
        return;
    if (_animating == NO && animating == YES) {
        _animating = YES;
        [[self shapeLayer] addAnimation:self.animationGroup forKey:@"pulse:"];
    } else if (_animating == YES && animating == NO) {
        _animating = NO;
    }
}

- (void)sendCallback
{
    if (self.delegate)
        [self.delegate radarPulseAchievedCallbackFraction];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.animating) {
        [[self shapeLayer] addAnimation:self.animationGroup forKey:@"pulse"];
    }
}

- (void)animationDidStart:(CAAnimation *)anim
{
    NSTimeInterval delay = self.callbackFraction * animationDuration;
    [self performSelector:@selector(sendCallback)
               withObject:nil
               afterDelay:delay];
}

@end
