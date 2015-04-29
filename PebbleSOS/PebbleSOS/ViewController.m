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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.readPermissions = @[@"email", @"user_friends", @"publish_actions"];
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];
    
    
    UIButton *postData = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [postData setTitle:@"post" forState:UIControlStateNormal];
    postData.frame = CGRectMake(38, 364 ,157,25);
    [postData addTarget:self action:@selector(postData:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:postData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) postData:(UIButton *) sender {
    
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        [[[FBSDKGraphRequest alloc]
          initWithGraphPath:@"me/feed"
          parameters: @{ @"message" : @"second message1, automatic?!"}
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
                      parameters: @{ @"message" : @"second message, automatic?!"}
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

@end
