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
    /*static Boolean lastOn = false;
    if (lastOn == false) {
        NSLog(@"Beginning broadcast");
        [[self beaconModel] beginBroadcasting];
    } else {
        NSLog(@"Ending broadcast");
        [[self beaconModel] beginBroadcasting];
    }*/
    
    NSString *bodyData = @"HELLO";
    
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://brushapp.herokuapp.com/brush"]];
    
    // Set the request's content type to application/x-www-form-urlencoded
    [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // Designate the request a POST request and specify its body data
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    
    [NSURLConnection sendAsynchronousRequest:postRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data,
                                               NSError *connectionError) {
                               NSLog(@"Got response:");
                               NSString *dataString = [[NSString alloc] initWithData:data
                                                                            encoding:NSUTF8StringEncoding];
                               NSLog(@"%@", dataString);
                           }];
    
    /*
    NSString *empty = @"";
    if([self.loginTextfield.text isEqualToString:empty]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!" message:@"Login name cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if([self.passwordTextfield.text isEqualToString:empty]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!" message:@"Password field cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!" message:@"Unknown error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    }
     */
}

- (IBAction)Login:(UIButton *)sender {
    NSString *empty = @"";
    if([self.loginTextfield.text isEqualToString:empty]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!" message:@"Login name cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else if([self.passwordTextfield.text isEqualToString:empty]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!" message:@"Password field cannot be empty." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else{
        
        if(![self checkLogin]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nice try!" message:@"Login failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        else{
            /* Login successful */
        }
    }
}

- (Boolean) checkLogin
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
