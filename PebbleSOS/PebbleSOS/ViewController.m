//
//  ViewController.m
//  PebbleSOS
//
//  Created by Sally Yang Jing Ou on 2015-04-28.
//  Copyright (c) 2015 Sally Yang Jing Ou. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@import CoreLocation;

@interface ViewController () <CLLocationManagerDelegate>

@end

@implementation ViewController{
    CLLocationManager *locationManager;
    
    CGFloat latitude;
    CGFloat longitude;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    //loginButton.readPermissions = @[@"email", @"user_friends"];
    loginButton.publishPermissions = @[@"publish_actions"];
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];
    
    
    UIButton *postData = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [postData setTitle:@"post" forState:UIControlStateNormal];
    postData.frame = CGRectMake(38, 364 ,157,25);
    [postData addTarget:self action:@selector(postData:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:postData];
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    [locationManager requestAlwaysAuthorization];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManager Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = locations[0];
    latitude = location.coordinate.latitude;
    longitude = location.coordinate.longitude;
    
    NSString *message = [NSString stringWithFormat:@"My location: %f, %f", latitude, longitude];
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
}

- (void) postData:(UIButton *) sender {
    [locationManager startUpdatingLocation];

}

@end
