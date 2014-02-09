//
//  BRRadarView.h
//  Brush
//
//  Created by Riley Avron on 2/8/14.
//  Copyright (c) 2014 Riley Avron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRRadarBackgroundView.h"
#import "BRRadarPulseView.h"
#import "BRRadarPingView.h"

@interface BRRadarView : UIView <BRRadarPulseViewDelegate>

@property (nonatomic) BOOL animating;

// 1 is farthest, 0 is closest
@property (nonatomic) CGFloat distanceFraction;
@property (nonatomic) BOOL pinging;

@end
