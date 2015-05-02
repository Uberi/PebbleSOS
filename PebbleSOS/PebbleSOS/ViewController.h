//
//  ViewController.h
//  PebbleSOS
//
//  Created by Sally Yang Jing Ou on 2015-04-28.
//  Copyright (c) 2015 Sally Yang Jing Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *FBLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *pebbleSOSButton;
@property (weak, nonatomic) IBOutlet UIButton *permissionButton;

-(void) postHelp;

@end

