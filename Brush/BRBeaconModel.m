//
//  BRBrushModel.m
//  Brush
//
//  Created by Riley Avron on 2/8/14.
//  Copyright (c) 2014 Riley Avron. All rights reserved.
//

#import "BRBeaconModel.h"

NSString *const UUIDString = @"16BE5001-F2DA-417D-8E52-48B5043D5642";
NSString *const detectIdent = @"com.RileyAvron.Brush.detect";
NSString *const broadcastIdent = @"com.RileyAvron.Brush.broadcast";

@interface BRBeaconModel ()

@property BOOL poweringUp;

@end

@implementation BRBeaconModel

- (id)init
{
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (void)beginMonitoring
{
    [[self locationManager] startMonitoringForRegion:[self detectRegion]];
}

- (void)beginBroadcasting
{
    NSDictionary *beaconDict = [[self broadcastRegion] peripheralDataWithMeasuredPower:nil];
    [[self peripheralManager] startAdvertising:beaconDict];
}

- (void)endBroadcasting
{
    [[self peripheralManager] stopAdvertising];
}

// lazy loader
- (NSUUID *)brushUUID
{
    if (_brushUUID == nil) {
        _brushUUID = [[NSUUID alloc] initWithUUIDString:UUIDString];
    }
    return _brushUUID;
}

// lazy loader
- (CLBeaconRegion *)detectRegion
{
    if (_detectRegion == nil) {
        _detectRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.brushUUID
                                                           identifier:detectIdent];
    }
    return _detectRegion;
}

// lazy loader
- (CLBeaconRegion *)broadcastRegion
{
    if (_broadcastRegion == nil) {
        CLBeaconMajorValue majVal = 0;
        CLBeaconMinorValue minVal = 0;
        _broadcastRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.brushUUID
                                                                   major:majVal
                                                                   minor:minVal
                                                              identifier:broadcastIdent];
    }
    return _broadcastRegion;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Entered region");
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exited region");
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
        NSLog(@"Entered region via didDetermineState");
        break;
        
        case CLRegionStateOutside:
        NSLog(@"Exited region via didDetermineState");
        
        default:
        break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error!");
}

#pragma mark - CBPeripheralMangaerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state < CBPeripheralManagerStatePoweredOn) {
        NSLog(@"State of BT peripheral less than ON");
    } else {
        NSLog(@"BT peripheral powered ON");
    }
}

@end
