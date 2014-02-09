//
//  BRViewController.m
//  Brush
//
//  Created by Riley Avron on 2/8/14.
//  Copyright (c) 2014 Riley Avron. All rights reserved.
//

#import "BRBeaconActiveViewController.h"

const NSInteger downwardAnimationDistance = 115;

@interface BRBeaconActiveViewController ()

@end

@implementation BRBeaconActiveViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _beaconModel = [[BRBeaconModel alloc] init];
        _beaconModel.delegate = self;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *img = [UIImage imageNamed:@"brush_load"];
    [[self bg] setImage:img];
    
    [self logoutButton].hidden = YES;
    
    [[self loginTextfield] setPlaceholder:@"Username"];
    [[self twitterTextfield] setPlaceholder:@"Twitter Handle"];
    [[self loginTextfield] setAutocorrectionType:UITextAutocorrectionTypeNo];
    [[self twitterTextfield] setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    
    CGRect radarRect = CGRectMake(10, 165, 300, 300);
    [self setRadarView:[[BRRadarView alloc] initWithFrame:radarRect]];
    [[self radarView] setAlpha:0];
    [[self view] addSubview:[self radarView]];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"At load-time, %ld regions monitored", (unsigned long)[[self beaconModel] numRegionsMonitored]);
}

- (IBAction)CreateAccount:(UIButton *)sender {
    
    NSString *empty = @"";
    if([self.loginTextfield.text isEqualToString:empty]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!" message:@"Login name cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    NSDictionary *dataDict = @{@"method": @"new_user", @"username": self.loginTextfield.text, @"twitter": self.twitterTextfield.text};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSLog(@"Json data: %@", jsonData);
    NSString *dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"JSON data as string: %@", dataString);
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://brushapp.herokuapp.com/brush"]];
    
    // Set the request's content type to application/x-www-form-urlencoded
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Designate the request a POST request and specify its body data
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:jsonData];
    
    
    
    [NSURLConnection sendAsynchronousRequest:postRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data,
                                               NSError *connectionError) {
                               NSLog(@"Got response:");
                               NSString *dataString = [[NSString alloc] initWithData:data
                                                                            encoding:NSUTF8StringEncoding];
                               NSLog(@"%@", dataString);
                               
                               if([dataString isEqualToString:@"false"]){
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!"
                                                                                   message:@"User already exists."
                                                                                  delegate:self
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil];
                                   [alert show];
                               }
                               
                               else if( dataString.length > 10){
                                   NSLog(@"Unknown error");
                               }
                               
                               
                               unsigned int majorMinor = dataString.intValue;
                               
                               [self setMinor: majorMinor & (0x0000FFFF)];
                               [self setMajor:(majorMinor >> 16) & (0x0000FFFF)];
                               
                               NSLog(@"Maj: %d Min: %d", [self major], [self minor]);
                               
                           }];
}

- (IBAction)Login:(UIButton *)sender {
    
    if([[self beaconModel] isTransmitting] || [[self beaconModel] isMonitoring]){
        [[self beaconModel] endBroadcasting];
        [[self beaconModel] endMonitoring];
        [[self loginButton] setTitle:@"Login" forState:(UIControlStateNormal)];
        
        [self loginTextfield].enabled = YES;
        [self twitterTextfield].enabled = YES;
        
        [self createButton].enabled = YES;
        
        [[self radarView] setAnimating:NO];
        [[self radarView] setPinging:NO];
        [[self radarView] setDistanceFraction:1.0];
        
        [UIView animateWithDuration:0.75
                         animations:^(void) {
                             [[self bg] setAlpha:1];
                             [[self radarView] setAlpha:0];
                         }];
        return;
    }
    
    NSString *empty = @"";
    if([self.loginTextfield.text isEqualToString:empty]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!"
                                                        message:@"Login name cannot be empty."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    NSDictionary *dataDict = @{@"method": @"get_user", @"username": self.loginTextfield.text};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSLog(@"Json data: %@", jsonData);
    NSString *dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"JSON data as string: %@", dataString);
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://brushapp.herokuapp.com/brush"]];
    
    // Set the request's content type to application/x-www-form-urlencoded
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Designate the request a POST request and specify its body data
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:jsonData];
    
    [NSURLConnection sendAsynchronousRequest:postRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data,
                                               NSError *connectionError) {
                               NSLog(@"Got response:");
                               NSString *dataString = [[NSString alloc] initWithData:data
                                                                            encoding:NSUTF8StringEncoding];
                               NSLog(@"%@", dataString);
                               [self handleLoginResponse:dataString];
                           }];
}

- (void)handleLoginResponse:(NSString *)response
{
    BOOL valid;
    NSCharacterSet *digitCharSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringCharSet = [NSCharacterSet characterSetWithCharactersInString:response];
    valid = [digitCharSet isSupersetOfSet:inStringCharSet];
    
    if (valid == FALSE) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!" message:@"Login failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        unsigned int majorMinor = response.intValue;
        [self setMinor: majorMinor & (0x0000FFFF)];
        [self setMajor:(majorMinor >> 16) & (0x0000FFFF)];
        
        NSLog(@"Maj: %d Min: %d", [self major], [self minor]);
        
        [[self loginTextfield] resignFirstResponder];
        [[self loginButton] setTitle:@"Logout" forState:(UIControlStateNormal)];
        
        [self loginTextfield].enabled = NO;
        [self twitterTextfield].enabled = NO;
        [self createButton].enabled = NO;
        
        [UIView animateWithDuration:0.75
                         animations:^(void) {
                             [[self bg] setAlpha:0];
                             [[self radarView] setAlpha:1];
                         }];
        
        [self beginBroadcast];
    }
}

- (void) beginBroadcast
{
    [[self beaconModel] beginMonitoring];
    [[self beaconModel] beginBroadcastingWithMajor:[self major] minor:[self minor]];
    [[self radarView] setAnimating:YES];
    [[self radarView] setPinging:NO];
}

- (void)endLocationServices
{
    [[self beaconModel] endBroadcasting];
    [[self beaconModel] endMonitoring];
    [[self radarView] setAnimating:NO];
    [[self radarView] setPinging:NO];
}

#pragma mark - BRBeaconModelDelegate

- (void)beaconDetected
{
    [[self radarView] setPinging:YES];
    [[self radarView] setDistanceFraction:1];
}

- (void)beaconLost
{
    [[self radarView] setPinging:NO];
    [[self radarView] setDistanceFraction:1];
}

- (void)beaconDetectedWithStrength:(CGFloat)strength
{
    NSLog(@"Beacon detected w/ strength %f in VC", strength);
    [[self radarView] setPinging:YES];
    [[self radarView] setDistanceFraction:strength];
}

@end
