//
//  BRViewController.m
//  Brush
//
//  Created by Riley Avron on 2/8/14.
//  Copyright (c) 2014 Riley Avron. All rights reserved.
//

#import "BRBeaconActiveViewController.h"

@interface BRBeaconActiveViewController ()

@end

@implementation BRBeaconActiveViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _beaconModel = [[BRBeaconModel alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.passwordTextfield.secureTextEntry = YES;
    [[self beaconModel] beginMonitoring];
}

- (IBAction)CreateAccount:(UIButton *)sender {
    
    NSString *empty = @"";
    if([self.loginTextfield.text isEqualToString:empty]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!" message:@"Login name cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    NSDictionary *dataDict = @{@"method": @"new_user", @"username": self.loginTextfield.text};
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
                               
                               unsigned int majorMinor = dataString.intValue;
                               
                               [self setMinor: majorMinor & (0x0000FFFF)];
                               [self setMajor:(majorMinor >> 16) & (0x0000FFFF)];
                               
                               NSLog(@"Maj: %d Min: %d", [self major], [self minor]);
                               
                           }];
}

- (IBAction)Login:(UIButton *)sender {
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
    
    /*
    else if([self.passwordTextfield.text isEqualToString:empty]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!" message:@"Password field cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
     */
    
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
                               
                               if([dataString isEqualToString:@"false"]){
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!" message:@"Login failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                   [alert show];
                               }
                               else{
                                   unsigned int majorMinor = dataString.intValue;
                                   
                                   [self setMinor: majorMinor & (0x0000FFFF)];
                                   [self setMajor:(majorMinor >> 16) & (0x0000FFFF)];
                                   
                                   NSLog(@"Maj: %d Min: %d", [self major], [self minor]);
                                   
                                   [self beginBroadcast];
                               }
                        }];
    
    }

- (void) beginBroadcast
{
    static Boolean lastOn = false;
    if (lastOn == false) {
        [[self beaconModel] beginBroadcastingWithMajor:[self major] minor:[self minor]];
        lastOn = true;
    } else {
        [[self beaconModel] endBroadcasting];
        lastOn = false;
    }
    
    return;
}


@end
