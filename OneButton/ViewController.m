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
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loading;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.button.enabled = NO;
    self.button.alpha = 0.5;
    
    [self.loading startAnimating];
    
    
    if ([[PFUser currentUser] isNew]) {
        //wait untill save
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //
            if (succeeded) {
                [self getPushes];
            }
            
            if (error) {
                [self showError:error];
            }
            
        }];
        
    } else {
        [self getPushes];
    }
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)showError:(NSError*)error {
    self.label.text = [NSString stringWithFormat:@"%@",error.localizedDescription];
    self.button.enabled = NO;
    self.button.alpha = 0.5;

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
                                block:^(NSNumber *result, NSError *error) {
                                    
                                    [self.loading stopAnimating];
                                    NSLog(@"result %@ error %@",result,error);
                                    
                                    if (result) {
                                        NSNumber* value = result;
                                        
                                        self.label.text = [NSString stringWithFormat:@"You can push button %@ times. \n Every time you push button random person will recieve your push",value];
                                        
                                        if (value.intValue > 0) {
                                            self.button.enabled = YES;
                                            self.button.alpha = 1;

                                        } else {
                                            self.button.enabled = NO;
                                            self.button.alpha = 0.5;
                                        }
                                        
                                        
                                        
                                        
                                    }
                                    
                                }];
}

- (IBAction)onPush:(id)sender {
    NSLog(@"onPush");

    [self.loading startAnimating];
    
    self.button.enabled = NO;
    self.button.alpha = 0.5;
    
    
    PFUser* user = [PFUser currentUser];
    NSString* userId = user.objectId;
    
    PFInstallation* install = [PFInstallation currentInstallation];
    NSString* installationId = install.installationId;
    
    [PFCloud callFunctionInBackground:@"sendPush"
                       withParameters:@{@"userId":userId, @"installationId":installationId}
                                block:^(NSNumber *result, NSError *error) {
                                    
                                    [self.loading stopAnimating];
                                    NSLog(@"result %@ error %@",result,error);
                                    
                                    if (result) {
                                        NSNumber* value = result;
                                        
                                        self.label.text = [NSString stringWithFormat:@"You can push button %@ times. \n Every time you push button random person will recieve your push",value];

                                        
                                        if (value.intValue > 0) {
                                            self.button.enabled = YES;
                                            self.button.alpha = 1;
                                            
                                        } else {
                                            self.button.enabled = NO;
                                            self.button.alpha = 0.5;
                                        }
                                        
                                        
                                        
                                        
                                    }
                                    
                                }];
    
    
}

@end
