//
//  BRBrushModel.h
//  Brush
//
//  Created by Riley Avron on 2/8/14.
//  Copyright (c) 2014 Riley Avron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BRBeaconModelDelegate <NSObject>

- (void)beaconDetected;
- (void)beaconLost;
- (void)beaconDetectedWithStrength:(CGFloat)strength;

@end

@interface BRBeaconModel : NSObject <CLLocationManagerDelegate, CBPeripheralManagerDelegate>
{
    // ivars
}

// properties
@property (readonly, nonatomic) BOOL isMonitoring;
@property (readonly, nonatomic) BOOL isTransmitting;
@property (weak, nonatomic) id <BRBeaconModelDelegate> delegate;

// methods
- (void)beginMonitoring;
- (void)endMonitoring;
- (void)beginBroadcastingWithMajor:(uint16_t)major minor:(uint16_t)minor;
- (void)endBroadcasting;

- (NSUInteger)numRegionsMonitored;

@end
