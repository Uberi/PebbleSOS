//
//  AppDelegate.h
//  PebbleSOS
//
//  Created by Sally Yang Jing Ou on 2015-04-28.
//  Copyright (c) 2015 Sally Yang Jing Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PebbleKit/PebbleKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PBWatch *connectedWatch;
@end

