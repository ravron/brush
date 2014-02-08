//
//  BRBrushModel.m
//  Brush
//
//  Created by Riley Avron on 2/8/14.
//  Copyright (c) 2014 Riley Avron. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "BRBeaconModel.h"

NSString *const UUIDString = @"16BE5001-F2DA-417D-8E52-48B5043D5642";
NSString *const detectIdent = @"com.RileyAvron.Brush.detect";
NSString *const broadcastIdent = @"com.RileyAvron.Brush.broadcast";

@implementation BRBeaconModel

- (id)init
{
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return self;
}

- (void)beginMonitoring
{
    [[self locationManager] startMonitoringForRegion:[self detectRegion]];
}

- (void)beginBroadcasting
{
    
}

- (NSUUID *)brushUUID
{
    if (_brushUUID == nil) {
        _brushUUID = [[NSUUID alloc] initWithUUIDString:UUIDString];
    }
    return _brushUUID;
}

- (CLBeaconRegion *)detectRegion
{
    if (_detectRegion == nil) {
        _detectRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.brushUUID identifier:detectIdent];
    }
    return _detectRegion;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error!");
}

@end
