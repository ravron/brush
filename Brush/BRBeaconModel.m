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
NSString *const beaconIDKey = @"user_id_2";
NSString *const timestampKey = @"brush_time";
NSString *const myBeaconIDKey = @"user_id_1";
NSString *const latitudeKey = @"lat";
NSString *const longitudeKey = @"lon";

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
@property (strong, nonatomic, readonly) NSNumber *myBeaconID;

@property (readwrite) BOOL isMonitoring;
@property (readwrite) BOOL isTransmitting;

@end

@implementation BRBeaconModel

- (id)init
{
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        _locationManager.distanceFilter = 1000;
        
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (void)beginMonitoring
{
    NSLog(@"Beginning monitor");
    [[self locationManager] startMonitoringForRegion:[self detectRegion]];
    [self setIsMonitoring:YES];
    //NSLog(@"Monitoring %d regions", [[[self locationManager] monitoredRegions] count]);
}

- (void)endMonitoring
{
    NSLog(@"Ending monitor");
    [[self locationManager] stopMonitoringForRegion:[self detectRegion]];
    [[self locationManager] stopRangingBeaconsInRegion:[self detectRegion]];
    
    
    [self setIsMonitoring:NO];
}

- (NSUInteger)numRegionsMonitored
{
    return [[[self locationManager] monitoredRegions] count];
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
    [self setIsTransmitting:YES];
}

- (void)endBroadcasting
{
    NSLog(@"Ending broadcast");
    [[self peripheralManager] stopAdvertising];
    [self setIsTransmitting:NO];
}

- (NSNumber *)numberWithMajor:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor
{
    uint32_t numPrimitive = ((uint32_t)major << 16) | (uint32_t)minor;
    NSNumber *num = [NSNumber numberWithInt:numPrimitive];
    return num;
}

- (void)sendJSONFromDict:(NSDictionary *)dict
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:
                                        [NSURL URLWithString:@"http://brushapp.herokuapp.com/brush"]];
    
    // Set the request's content type to application/json
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Designate the request a POST request and specify its body data
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:jsonData];
    
    [NSURLConnection sendAsynchronousRequest:postRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data,
                                               NSError *connectionError) {
                               NSString *dataString = [[NSString alloc] initWithData:data
                                                                            encoding:NSUTF8StringEncoding];
                               NSLog(@"Received back: %@", dataString);
                           }];
}

#pragma mark Getters

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
        [_detectRegion setNotifyEntryStateOnDisplay:YES];
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

// generator
- (NSNumber *)myBeaconID
{
    return [self numberWithMajor:[self majorValue] minor:[self minorValue]];
}

#pragma mark - CLLocationManagerDelegate
#pragma mark Beacon methods

/*
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    return;
    NSLog(@"Entered region");
    [[self locationManager] startRangingBeaconsInRegion:[self detectRegion]];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    return;
    NSLog(@"Exited region");
    [[self locationManager] stopRangingBeaconsInRegion:[self detectRegion]];
}
 */

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
            NSLog(@"Entered region, commencing ranging");
            [[self locationManager] startRangingBeaconsInRegion:[self detectRegion]];
            break;
            
        case CLRegionStateOutside:
            NSLog(@"Exited region, ceasing ranging");
            [[self locationManager] stopRangingBeaconsInRegion:[self detectRegion]];
            break;
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    for (CLBeacon *b in beacons) {
        // check that proximity is "near" or "immediate"
        CLProximity proximity = b.proximity;
        NSInteger rssi = b.rssi;
        NSLog(@"RSSI: %ld", (long)rssi);
        if (proximity != CLProximityNear && proximity != CLProximityImmediate) {
            // if not, continue
//            NSLog(@"Beacon in proximity, but not close enough.");
            continue;
        }
        
        // generate beacon ID as a 32-bit number, with the major as the more significant bits
        NSNumber *beaconID = [self numberWithMajor:[b.major unsignedIntegerValue]
                                             minor:[b.minor unsignedIntegerValue]];
        // generate timestamp
        NSTimeInterval timestampPrimitive = [[NSDate date] timeIntervalSince1970];
        NSNumber *timestamp = [NSNumber numberWithInteger:(NSInteger)timestampPrimitive];
        
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
            
            // put dict into seen list, and into pending posts (pending location update)
            [[self beaconsSeen] addObject:brushEvent];
            [[self pendingPosts] addObject:brushEvent];
            
            // start location acquisition
            [[self locationManager] startUpdatingLocation];
            
            NSLog(@"New brush occurred between:\n%i (self) and\n%i",
                  [[self myBeaconID] intValue], [beaconID intValue]);
        } else if ([existingInstances count] == 1) {
            // if it has one element, it's been seen before; check that that was > 2 hrs ago
            NSDictionary *brushEvent = [existingInstances anyObject];
            NSNumber *objTimestamp = [brushEvent objectForKey:timestampKey];
            NSDate *objDate = [NSDate dateWithTimeIntervalSince1970:[objTimestamp intValue]];
            NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:objDate];
            
            if (timeDiff > 60 * 60 * 2) {
                // if it has been longer than 2 hours, update the timestamp and post it
                objTimestamp = timestamp;
                
                // put dict into pending posts (pending location update) (it's already in
                // seenBeacons)
                [[self pendingPosts] addObject:brushEvent];
                [[self locationManager] startUpdatingLocation];
            } else {
                // otherwise reset the timestamp to start counting down another two hours
                objTimestamp = timestamp;
            }
        } else {
            NSAssert(1 == 0, @"There are %lu objects in existingInstances; should be 0 or 1.", (unsigned long)[existingInstances count]);
        }
    }
}

#pragma mark Location methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"Got locationManager update");
    // one update is sufficient for low accuracy, stop updating
    [[self locationManager] stopUpdatingLocation];
    
    // extract lat/long
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coords = location.coordinate;
    NSNumber *lat = [NSNumber numberWithDouble:coords.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:coords.longitude];
    
    // finish putting together, and post, the pending posts
    for (int i = 0; i < [[self pendingPosts] count]; i++) {
        // grab the unfinished brush event dict from pending post
        NSDictionary *incompleteBrushEvent = [[self pendingPosts] objectAtIndex:i];

        // copy into a mutable dict
        NSMutableDictionary *brushEvent = [NSMutableDictionary dictionaryWithDictionary:incompleteBrushEvent];
        
        // generate my ID number and add to brushEvent
        NSNumber *myBeaconID = [self numberWithMajor:[self majorValue]
                                               minor:[self minorValue]];
        [brushEvent setValue:myBeaconID forKey:myBeaconIDKey];
        
        // add latitude and longitude to brushEvent
        [brushEvent setValue:lat forKey:latitudeKey];
        [brushEvent setValue:lon forKey:longitudeKey];
        [brushEvent setValue:@"new_brush" forKey:@"method"];
        NSLog(@"Brush event: %@", brushEvent);
        
        // generate JSON and send to server
        [self sendJSONFromDict:[NSDictionary dictionaryWithDictionary:brushEvent]];
        
        // remove corresponding incomplete object from pending posts since
        // it's no longer pending
        [[self pendingPosts] removeObject:incompleteBrushEvent];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error in location manager %@!", manager);
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
