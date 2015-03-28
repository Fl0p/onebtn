//
//  ViewController.m
//  OneButton
//
//  Created by Flop on 28/03/2015.
//  Copyright (c) 2015 OB. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UILabel* label;
@property (nonatomic, strong) IBOutlet UIButton* button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPush:(id)sender {
    NSLog(@"onPush");
    
    PFUser* user = [PFUser currentUser];
    NSString* userId = user.objectId;
    
    PFInstallation* install = [PFInstallation currentInstallation];
    NSString* installationId = install.installationId;
    
    [PFCloud callFunctionInBackground:@"getPushes"
                       withParameters:@{@"userId":userId, @"installationId":installationId}
                                block:^(NSArray *results, NSError *error) {
                                    NSLog(@"result %@ error %@",results,error);
                                }];
}

@end
