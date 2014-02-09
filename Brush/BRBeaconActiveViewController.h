//
//  BRViewController.h
//  Brush
//
//  Created by Riley Avron on 2/8/14.
//  Copyright (c) 2014 Riley Avron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRBeaconModel.h"

@interface BRBeaconActiveViewController : UIViewController

@property (strong, nonatomic) BRBeaconModel *beaconModel;

@property (weak, nonatomic) IBOutlet UITextField *loginTextfield;
@property (weak, nonatomic) IBOutlet UITextField *twitterTextfield;
@property (weak, nonatomic) IBOutlet UIImageView *bg;

@property NSString *loginResult;

@property uint16_t major;
@property uint16_t minor;

- (void)endLocationServices;

@end
