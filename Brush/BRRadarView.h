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

@interface BRRadarView : UIView <BRRadarPulseViewDelegate>

@property (nonatomic) BOOL animating;

@end