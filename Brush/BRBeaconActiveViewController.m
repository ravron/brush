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
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.passwordTextfield.secureTextEntry = YES;
}

- (IBAction)CreateAccount:(UIButton *)sender {
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
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://brushapp.herokuapp.com/brush"]];
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = @"Hello, JP!";
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //[self.loginTextfield setText:<#(NSString *)#>"Shit was jokes"];
    
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
