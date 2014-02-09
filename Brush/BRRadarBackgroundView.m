//
//  BRRadarBackgroundView.m
//  Brush
//
//  Created by Riley Avron on 2/8/14.
//  Copyright (c) 2014 Riley Avron. All rights reserved.
//

#import "BRRadarBackgroundView.h"

CGFloat const lineFractionGradient = .15;
CGFloat const lineThickness = 2;
CGFloat sideLen, minX, midX, maxX, minY, midY, maxY;
UIColor *lineColor;


@implementation BRRadarBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert(frame.size.height == frame.size.width, @"BRRadarView must be instantiated with a square frame!");
        
        lineColor = [UIColor colorWithWhite:0.75 alpha:1.0];
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
        CGRectMake(minX, midY - lineThickness / 2,
                   (sideLen / 2) + lineThickness / 2, lineThickness),
        CGRectMake(midX - lineThickness / 2, minY, lineThickness,
                   (sideLen / 2) + lineThickness / 2),
        CGRectMake(midX - lineThickness / 2, midY - lineThickness / 2,
                   sideLen + lineThickness / 2, lineThickness),
        CGRectMake(midX - lineThickness / 2, midY - lineThickness / 2,
                   lineThickness, sideLen + lineThickness / 2)
    };
    
    // gradient paths, starting with left, going CW
    CGPoint pointPairs[4][2] = {
        {CGPointMake(minX, midY), CGPointMake(midX + lineThickness / 2, midY)},
        {CGPointMake(midX, minY), CGPointMake(midX, midY + lineThickness / 2)},
        {CGPointMake(maxX, midY), CGPointMake(midX - lineThickness / 2, midY)},
        {CGPointMake(midX, maxY), CGPointMake(midX, midY - lineThickness / 2)}
    };
    
    // perform clip/gradient operation for all four lines
    for (int i = 0; i < 4; i++) {
        CGContextSaveGState(c);
        CGContextClipToRect(c, clipRects[i]);
        CGContextDrawLinearGradient(c, lineGrad, pointPairs[i][0], pointPairs[i][1], 0);
        CGContextRestoreGState(c);
    }
}

@end
