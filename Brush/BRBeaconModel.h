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

// Location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;

// BT
@property (strong, nonatomic) NSUUID *brushUUID;
@property (strong, nonatomic) CLBeaconRegion *detectRegion;
@property (strong, nonatomic) CLBeaconRegion *broadcastRegion;

// State
@property (strong, nonatomic) NSMutableArray *pendingPosts;

@property (strong, nonatomic) NSMutableSet *beaconsSeen;

- (void)beginMonitoring;
- (void)beginBroadcasting;
- (void)endBroadcasting;

@end
