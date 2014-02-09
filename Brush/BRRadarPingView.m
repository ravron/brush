//
//  BRRadarPingView.m
//  Brush
//
//  Created by Riley Avron on 2/8/14.
//  Copyright (c) 2014 Riley Avron. All rights reserved.
//

#import "BRRadarPingView.h"

@interface BRRadarPingView ()
{
    CGFloat pingRatios[3];
    CGFloat sideLen, minX, midX, maxX, minY, midY, maxY;
    UIColor *strokeColor;
    CGFloat animationDuration;
    CGFloat lineWidth;
}
@property (strong, nonatomic) CAShapeLayer *shapeLayer;
@end

@implementation BRRadarPingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // constants
        pingRatios[0] = 0.2;
        pingRatios[1] = 0.5;
        pingRatios[2] = 0.8;
        sideLen = frame.size.height;
        minX = minY = 0;
        midX = midY = CGRectGetMidX(frame);
        maxX = maxY = CGRectGetMaxX(frame);
        strokeColor = [UIColor redColor];
        animationDuration = 3.5;
        lineWidth = 6;
        
        // inits
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.strokeColor = [strokeColor CGColor];
        _shapeLayer.frame = self.bounds;
        _shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        _shapeLayer.lineWidth = lineWidth;
        [[self layer] addSublayer:_shapeLayer];
    }
    return self;
}

- (void)displayPing:(CGFloat)pingRatio
{
    CGRect pingRect = CGRectMake(midX * (1 - pingRatio),
                                 midY * (1 - pingRatio),
                                 midX * pingRatio * 2,
                                 midY * pingRatio * 2);
    UIBezierPath *pingUIPath = [UIBezierPath bezierPathWithOvalInRect:pingRect];
    [[self shapeLayer] setPath:[pingUIPath CGPath]];
    
    CABasicAnimation *strokeColorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
    strokeColorAnimation.duration = animationDuration;
    strokeColorAnimation.fromValue = (__bridge id)[strokeColor CGColor];
    strokeColorAnimation.toValue = (__bridge id)[[UIColor clearColor] CGColor];
    [[self shapeLayer] addAnimation:strokeColorAnimation forKey:@"strokeColor"];
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
