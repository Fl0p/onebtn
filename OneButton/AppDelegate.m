//
//  AppDelegate.m
//  OneButton
//
//  Created by Flop on 28/03/2015.
//  Copyright (c) 2015 OB. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"o1nRlbm4VjDojTHih6CsI43cYaGMQZngH6pWa6Cy" clientKey:@"xBGm1B8kL4Ew3Vo9zRvByguSDb0V3TCCIrVSKNkF"];
    
    [PFUser enableAutomaticUser];
    
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    //Notifications
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings  settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
         UIRemoteNotificationTypeAlert|
         UIRemoteNotificationTypeSound];
    }
    
    
    [self parseRun];
 
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    PFUser* currentUser = [PFUser currentUser];
    
    
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation[@"user"] = currentUser;
    
    currentInstallation.channels = @[@"GLOBAL"];
    
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"saved installation%@",error);
        
        currentUser[@"installation"] = currentInstallation;
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"saved user%@",error);
        }];
        
    }];
    
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [self parseRun];
}


-  (void)parseRun {
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    [currentInstallation setObject:[NSDate date] forKey:@"lastRunDate"];
    
    NSInteger runCount = [currentInstallation objectForKeyedSubscript:@"runCount"]? [(NSString*)[currentInstallation objectForKeyedSubscript:@"runCount"] integerValue] : 0;
    runCount++;
    
    currentInstallation[@"runCount"] = [NSString stringWithFormat:@"%ld", (long)runCount];
    
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    NSString *bundleVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    currentInstallation[@"bundleVersion"] = bundleVersion;
    currentInstallation[@"bundleVersionString"] = bundleVersionString;
    
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //
        NSLog(@"saved installation%@",error);
    }];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0)
    {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
