//
//  ViewController.m
//  PebbleSOS
//
//  Created by Sally Yang Jing Ou on 2015-04-28.
//  Copyright (c) 2015 Sally Yang Jing Ou. All rights reserved.
//

#import "ViewController.h"
#import <PebbleKit/PebbleKit.h>

@import CoreLocation;

@interface ViewController () <CLLocationManagerDelegate>

@end

@implementation ViewController{
    CLLocationManager *locationManager;
    
    CGFloat latitude;
    CGFloat longitude;
    UIButton *postData;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.FBLoginButton.publishPermissions = @[@"publish_actions"];
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    [locationManager requestAlwaysAuthorization];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManager Delegate
//posting help message with exact location attached
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [locationManager stopUpdatingLocation];
    CLLocation *location = [locations lastObject];
    latitude = location.coordinate.latitude;
    longitude = location.coordinate.longitude;
    
    NSString *message = [NSString stringWithFormat:@"Emergency help needed!! My location: %f, %f. #PebbleSOS #PleaseHelp", latitude, longitude];
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        [[[FBSDKGraphRequest alloc]
          initWithGraphPath:@"me/feed"
          parameters: @{ @"message" : message}
          HTTPMethod:@"POST"]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"Post id:%@", result[@"id"]);
             }
         }];
    } else {
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                NSLog(@"error");
            } else if (result.isCancelled) {
                NSLog(@"cancels");
            } else {
                if ([result.grantedPermissions containsObject:@"publish_actions"]) {
                    [[[FBSDKGraphRequest alloc]
                      initWithGraphPath:@"me/feed"
                      parameters: @{ @"message" : message}
                      HTTPMethod:@"POST"]
                     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                         if (!error) {
                             NSLog(@"Post id:%@", result[@"id"]);
                         }
                     }];
                }
            }
        }];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your message is posted! Help is on the way" delegate:nil cancelButtonTitle:@"Thanks!" otherButtonTitles:nil];
    
    [alert show];
}
//updating current location
- (void) postHelp {
     [locationManager startUpdatingLocation];
}
//checking if the users have granted the app to post statues on facebook
- (IBAction)checkPermission:(id)sender{
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:@"Permission to publishing statuses to your Facebook has been granted" delegate:nil cancelButtonTitle:@"No problem!" otherButtonTitles:nil];
        
        [alert show];
    } else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                NSLog(@"error");
            } else if (result.isCancelled) {
                NSLog(@"cancels");
            } else {
                if ([result.grantedPermissions containsObject:@"publish_actions"]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:@"Permission to publishing statuses to your Facebook has been granted" delegate:nil cancelButtonTitle:@"No problem!" otherButtonTitles:nil];
                    [alert show];
                }
            }
        }];
    }
}

@end
