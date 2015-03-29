//
//  AppDelegate.m
//  OneButton
//
//  Created by Flop on 28/03/2015.
//  Copyright (c) 2015 OB. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "BFURL.h"
#import <AVFoundation/AVFoundation.h>
#import <SHAlertViewBlocks/SHAlertViewBlocks.h>
#import "ViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic) UIBackgroundTaskIdentifier taskId;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"o1nRlbm4VjDojTHih6CsI43cYaGMQZngH6pWa6Cy" clientKey:@"xBGm1B8kL4Ew3Vo9zRvByguSDb0V3TCCIrVSKNkF"];
    
    [PFUser enableAutomaticUser];
    
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    [self createParceUser];

    [self parseRun];
 
//    [self playRandomSound];
    
    return YES;
}

- (void)createParceUser {
    
    PFUser* currentUser = [PFUser currentUser];

    if (currentUser.objectId) {
        
        [self registerForRemoteNotification];
        
    } else {
        
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"saved user%@",error);
            [self registerForRemoteNotification];
        }];
    
    }
}

- (void)registerForRemoteNotification {
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
    

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    PFUser* currentUser = [PFUser currentUser];
    
    
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation[@"user"] = currentUser;
    
    [currentInstallation addUniqueObject:@"GLOBAL" forKey:@"channels"];
    
    NSString* userId = currentUser.objectId;
    
    [currentInstallation addUniqueObject:userId forKey:@"channels"];
    
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
//    self.taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] endBackgroundTask:self.taskId];
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

# pragma mark - Pushes handling

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    if (userInfo[@"fromUser"])
    {
        // open application with silent push
        NSURL *appUrl = [NSURL URLWithString:[NSString stringWithFormat:@"onebtnscheme://pushed?fromuser=%@",userInfo[@"fromUser"]]];
        [self processOpenURL:appUrl];
//        [[UIApplication sharedApplication] openURL:appUrl];
        
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

# pragma mark - Deep linking

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [self application:application openURL:url sourceApplication:nil annotation:nil];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [self processOpenURL:url];
}

- (BOOL)processOpenURL:(NSURL *)url
{
    if ([[url scheme] isEqualToString:@"onebtnscheme"])
    {
        if ([[url host] isEqualToString:@"pushed"])
        {
            BFURL *bfUrl = [BFURL URLWithURL:url];
            
            NSString *fromUser = bfUrl.targetQueryParameters[@"fromuser"];
            
            if (fromUser && ![[PFUser currentUser].objectId isEqualToString:fromUser])
            {
                UIAlertView *alertView = [UIAlertView SH_alertViewWithTitle:@"Uh-oh somebody pushed you!" andMessage:@"Push back?" buttonTitles:@[@"Yes"] cancelTitle:@"No" withBlock:^(NSInteger theButtonIndex) {
                    if (theButtonIndex != alertView.cancelButtonIndex)
                    {
                        PFUser* user = [PFUser currentUser];
                        NSString* userId = user.objectId;
                        
                        PFInstallation* install = [PFInstallation currentInstallation];
                        NSString* installationId = install.installationId;
                        
                        [(ViewController *)self.window.rootViewController sendPushToUserId:fromUser fromUserId:userId withInstallationId:installationId];
                    }
                }];
                [alertView show];

                if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground && [[UIApplication sharedApplication] applicationState] != UIApplicationStateInactive)
                {
                    [self playRandomSound];
                }
                
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)playRandomSound
{
//    if (![[[AVAudioSession sharedInstance] category] isEqualToString:AVAudioSessionCategoryPlayback] || [[AVAudioSession sharedInstance] categoryOptions] != AVAudioSessionCategoryOptionDefaultToSpeaker)
//    {
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker|AVAudioSessionCategoryOptionMixWithOthers error:nil];
//        [[AVAudioSession sharedInstance] setActive:YES error:nil];
//    }
    
    NSString *soundName = [NSString stringWithFormat:@"pushSound%d",arc4random_uniform(4)];
    NSURL *url = [[NSBundle mainBundle] URLForResource:soundName withExtension:@"wav"];
    
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player prepareToPlay];
    
    self.player = player;
//    self.player.delegate = self;
//    [[UIApplication sharedApplication] endBackgroundTask:self.taskId];
    
    if ([player play])
    {
//        self.taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[UIApplication sharedApplication] endBackgroundTask:self.taskId];
}
@end
