//
//  ViewController.h
//  OneButton
//
//  Created by Flop on 28/03/2015.
//  Copyright (c) 2015 OB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (void)sendPushToUserId:(NSString *)toUserId fromUserId:(NSString *)userId withInstallationId:(NSString *)installationId;

@end

