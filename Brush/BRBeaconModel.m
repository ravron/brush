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
NSString *const beaconIDKey = @"beaconIDKey";
NSString *const timestampKey = @"timestampKey";

@interface BRBeaconModel ()
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
@property CLBeaconMajorValue majorValue;
@property CLBeaconMinorValue minorValue;

@end

@implementation BRBeaconModel

- (id)init
{
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (void)beginMonitoring
{
    NSLog(@"Beginning monitor");
    [[self locationManager] startMonitoringForRegion:[self detectRegion]];
}

- (void)beginBroadcastingWithMajor:(uint16_t)major minor:(uint16_t)minor
{
    NSLog(@"Beginning broadcast");
    
    // make sure previous broadcast ends
    [[self peripheralManager] stopAdvertising];
    
    // set internal major and minor properties
    [self setMajorValue:(CLBeaconMajorValue)major];
    [self setMinorValue:(CLBeaconMinorValue)minor];
    
    // generate new beacon region with given major, minor
    CLBeaconRegion *newRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.brushUUID
                                                                        major:self.majorValue
                                                                        minor:self.minorValue
                                                                   identifier:broadcastIdent];

    // replace current broadcast region with new one
    [self setBroadcastRegion:newRegion];
    
    // start broadcast
    NSDictionary *beaconDict = [[self broadcastRegion] peripheralDataWithMeasuredPower:nil];
    [[self peripheralManager] startAdvertising:beaconDict];
}

- (void)endBroadcasting
{
    NSLog(@"Ending broadcast");
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
        // default to major = minor = 0 if not created for us by call to 
        _broadcastRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.brushUUID
                                                                   major:0
                                                                   minor:0
                                                              identifier:broadcastIdent];
    }
    return _broadcastRegion;
}

// lazy loader
- (NSMutableArray *)pendingPosts
{
    if (_pendingPosts == nil) {
        _pendingPosts = [NSMutableArray array];
    }
    return _pendingPosts;
}

// lazy loader
- (NSMutableSet *)beaconsSeen
{
    if (_beaconsSeen == nil) {
        _beaconsSeen = [NSMutableSet set];
    }
    return _beaconsSeen;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Entered region");
    [[self locationManager] startRangingBeaconsInRegion:[self detectRegion]];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exited region");
    [[self locationManager] stopRangingBeaconsInRegion:[self detectRegion]];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    for (CLBeacon *b in beacons) {
        NSLog(@"Maj:%@ Min:%@", b.major, b.minor);
        
        // generate beacon ID as a 32-bit number, with the major as the more significant bits
        uint32_t beaconIDPrimitive = ([b.major unsignedIntValue] << 16) & [b.minor unsignedIntValue];
        NSNumber *beaconID = [NSNumber numberWithInt:beaconIDPrimitive];
        
        // generate timestamp
        NSTimeInterval timestampPrimitive = [[NSDate date] timeIntervalSince1970];
        NSNumber *timestamp = [NSNumber numberWithDouble:timestampPrimitive];
        
        NSSet *existingInstances = [[self beaconsSeen] objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            NSDictionary *dict = obj;
            
            // check if the beacon b we're examining is implicated in this brushEvent obj
            NSNumber *objBeaconID = [dict objectForKey:beaconIDKey];
            if ([objBeaconID isEqualToNumber:beaconID] == FALSE) {
                // if it's not, this element does not get returned to be in existingInstances
                return NO;
            }

            return YES;
        }];
        

        if ([existingInstances count] == 0) {
            // if existingInstances is empty, this beacon hasn't been seen before; log it and post it
            // generate dictionary that will be inserted into set
            NSDictionary *brushEvent = @{timestampKey: timestamp, beaconIDKey: beaconID};
            [[self beaconsSeen] addObject:brushEvent];
#warning post it
        } else if ([existingInstances count] == 1) {
            // if it has one element, it's been seen before; check that that was > 2 hrs ago
            NSDictionary *brushEvent = [existingInstances anyObject];
            NSNumber *objTimestamp = [brushEvent objectForKey:timestampKey];
            NSDate *objDate = [NSDate dateWithTimeIntervalSince1970:[objTimestamp doubleValue]];
            NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:objDate];
            if (timeDiff > 60 * 60 * 2) {
                // if it has been longer than 2 hours, update the timestamp and post it
                objTimestamp = timestamp;
#warning post it
            } else {
                // otherwise reset the timestamp to start counting down another two hours
                objTimestamp = timestamp;
            }
        } else {
            NSAssert(1 == 0, @"There are %lu objects in existingInstances; should be 0 or 1.", (unsigned long)[existingInstances count]);
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coords = location.coordinate;
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error!");
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state < CBPeripheralManagerStatePoweredOn) {
        NSLog(@"State of BT peripheral less than ON");
    } else {
        NSLog(@"BT peripheral powered ON");
    }
}

@end
