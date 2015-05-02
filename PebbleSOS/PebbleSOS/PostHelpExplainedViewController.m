//
//  PostHelpExplainedViewController.m
//  PebbleSOS
//
//  Created by Sally Yang Jing Ou on 2015-04-30.
//  Copyright (c) 2015 Sally Yang Jing Ou. All rights reserved.
//

#import "PostHelpExplainedViewController.h"

@interface PostHelpExplainedViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lastLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastHeightConstraint;

@end

@implementation PostHelpExplainedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //optimized for iphone 4S
    if (self.view.frame.size.height < 500) {
        self.lastLabel.hidden = YES;
        self.lastHeightConstraint.constant = 24;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
