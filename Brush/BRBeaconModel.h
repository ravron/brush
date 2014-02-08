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

@interface BRBeaconModel : NSObject <CLLocationManagerDelegate, CBPeripheralManagerDelegate>
{
    // ivars
}

// properties
@property (readonly) BOOL isMonitoring;
@property (readonly) BOOL isTransmitting;

// methods
- (void)beginMonitoring;
- (void)endMonitoring;
- (void)beginBroadcastingWithMajor:(uint16_t)major minor:(uint16_t)minor;
- (void)endBroadcasting;

@end
