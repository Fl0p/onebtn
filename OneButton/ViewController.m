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
    
    [self getPushes];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getPushes {
    
    PFUser* user = [PFUser currentUser];
    NSString* userId = user.objectId;
    
    PFInstallation* install = [PFInstallation currentInstallation];
    NSString* installationId = install.installationId;
    
    [PFCloud callFunctionInBackground:@"getPushes"
                       withParameters:@{@"userId":userId, @"installationId":installationId}
                                block:^(PFObject *result, NSError *error) {
                                    
                                    
                                    NSLog(@"result %@ error %@",result,error);
                                    
                                    if (result) {
                                        NSNumber* value = [result objectForKey:@"value"];
                                        
                                        self.label.text = [NSString stringWithFormat:@"You can push button %@ times. \n Every time you push button random person will recieve your push",value];
                                        
                                        self.button.enabled = value.intValue > 0;
                                        
                                    }
                                    
                                }];
}

- (IBAction)onPush:(id)sender {
    NSLog(@"onPush");

}

@end
