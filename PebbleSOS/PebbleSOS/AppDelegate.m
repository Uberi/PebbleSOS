//
//  AppDelegate.m
//  PebbleSOS
//
//  Created by Sally Yang Jing Ou on 2015-04-28.
//  Copyright (c) 2015 Sally Yang Jing Ou. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "ViewController.h"


@interface AppDelegate () <PBPebbleCentralDelegate>

@end

@implementation AppDelegate

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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.connectedWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    NSLog(@"Last connected watch: %@", self.connectedWatch);
    
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:@"2ee28074-f8d3-4450-9774-6527e5514d1f"];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    
    [[PBPebbleCentral defaultCentral] setDelegate:self];
    
    [self.connectedWatch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if (isAppMessagesSupported) {
            NSLog(@"This Pebble supports app message!");
            
            [self.connectedWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
                NSLog(@"Received message: %@", update);
                [self performSelector:@selector(print) withObject:nil afterDelay:3.0];
                return YES;
            }];
        }
        else {
            NSLog(@":( - This Pebble does not support app message!");
        }
    }];
    
   
    
    [FBSDKLoginButton class];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}



-(void) pebbleCentral:(PBPebbleCentral *)central watchDidConnect:(PBWatch *)watch isNew:(BOOL)isNew {
    NSLog(@"Pebble connected: %@", [watch name]);

    self.connectedWatch = watch;
}

-(void) pebbleCentral:(PBPebbleCentral *)central watchDidDisconnect:(PBWatch *)watch {
    NSLog(@"Pebble disconnected: %@", [watch name]);

    if (self.connectedWatch == watch || [watch isEqual:self.connectedWatch]) {
        self.connectedWatch = nil;
    }
}

-(void) print{
    NSLog(@"called 1321");
    ViewController* vc = (ViewController*) self.window.rootViewController;
    [vc postHelp];
    NSLog(@"called");
}

@end
