//
//  BRRadarPulseView.h
//  Brush
//
//  Created by Riley Avron on 2/8/14.
//  Copyright (c) 2014 Riley Avron. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRRadarPulseViewDelegate <NSObject>

- (void)radarPulseViewFinishedAnimation;

@end

@interface BRRadarPulseView : UIView

@property (nonatomic) BOOL animating;
@property (weak, nonatomic) id <BRRadarPulseViewDelegate> delegate;

@end

