//
//  BRRadarPingView.h
//  Brush
//
//  Created by Riley Avron on 2/8/14.
//  Copyright (c) 2014 Riley Avron. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _BRPingDistance {
    BRPingDistanceImmediate = 0,
    BRPingDistanceNear,
    BRPingDistanceFar
} BRPingDistance;

@interface BRRadarPingView : UIView

- (void)displayPing:(CGFloat)pingRatio;

@end
