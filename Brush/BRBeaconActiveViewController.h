//
//  BRViewController.h
//  Brush
//
//  Created by Riley Avron on 2/8/14.
//  Copyright (c) 2014 Riley Avron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRBeaconModel.h"

NSMutableData* responseData;

@interface BRBeaconActiveViewController : UIViewController

@property (strong, nonatomic) BRBeaconModel *beaconModel;

@property (weak, nonatomic) IBOutlet UITextField *loginTextfield;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;

@end
