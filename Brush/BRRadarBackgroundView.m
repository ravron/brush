//
//  BRRadarBackgroundView.m
//  Brush
//
//  Created by Riley Avron on 2/8/14.
//  Copyright (c) 2014 Riley Avron. All rights reserved.
//

#import "BRRadarBackgroundView.h"

@interface BRRadarBackgroundView ()
{
    UIColor *lineColor;
    CGFloat lineFractionGradient;
    CGFloat lineWidth;
    CGFloat sideLen, minX, midX, maxX, minY, midY, maxY;
}
@end

@implementation BRRadarBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert(frame.size.height == frame.size.width, @"BRRadarBackgroundView must be instantiated with a square frame!");
        
        // constants
        lineColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        lineFractionGradient = 0.3;
        lineWidth = 2;

        
        [self setBackgroundColor:[UIColor clearColor]];
        
        sideLen = frame.size.height;
        minX = minY = 0;
        midX = midY = CGRectGetMidX(frame);
        maxX = maxY = CGRectGetMaxX(frame);
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    NSArray *colorArr = @[(id)[[UIColor whiteColor] CGColor], (id)[lineColor CGColor]];
    
    CGFloat locations[2] = {0, lineFractionGradient};
    CGGradientRef lineGrad = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)(colorArr), locations);
    
    // clipping rects, starting with left, going CW
    CGRect clipRects[4] = {
        CGRectMake(minX, midY - lineWidth / 2,
                   (sideLen / 2) + lineWidth / 2, lineWidth),
        CGRectMake(midX - lineWidth / 2, minY, lineWidth,
                   (sideLen / 2) + lineWidth / 2),
        CGRectMake(midX - lineWidth / 2, midY - lineWidth / 2,
                   sideLen + lineWidth / 2, lineWidth),
        CGRectMake(midX - lineWidth / 2, midY - lineWidth / 2,
                   lineWidth, sideLen + lineWidth / 2)
    };
    
    // gradient paths, starting with left, going CW
    CGPoint pointPairs[4][2] = {
        {CGPointMake(minX, midY), CGPointMake(midX + lineWidth / 2, midY)},
        {CGPointMake(midX, minY), CGPointMake(midX, midY + lineWidth / 2)},
        {CGPointMake(maxX, midY), CGPointMake(midX - lineWidth / 2, midY)},
        {CGPointMake(midX, maxY), CGPointMake(midX, midY - lineWidth / 2)}
    };
    
    // perform clip/gradient operation for all four lines
    for (int i = 0; i < 4; i++) {
        CGContextSaveGState(c);
        CGContextClipToRect(c, clipRects[i]);
        CGContextDrawLinearGradient(c, lineGrad, pointPairs[i][0], pointPairs[i][1], 0);
        CGContextRestoreGState(c);
    }
    
    CGContextSetLineWidth(c, 1);
    CGContextSetStrokeColorWithColor(c, [lineColor CGColor]);
    
    CGFloat ringDistances[3] = {0.2, 0.5, 0.8};
    for (int i = 0; i < 3; i++) {
        CGFloat ringDistance = ringDistances[i];
        CGRect ringRect = CGRectMake(midX * (1 - ringDistance),
                                     midY * (1 - ringDistance),
                                     midX * ringDistance * 2,
                                     midY * ringDistance * 2);

        CGContextStrokeEllipseInRect(c, ringRect);
    }
}

@end
