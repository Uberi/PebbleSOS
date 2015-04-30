//
//  WhatIsPebbleSOSViewController.m
//  PebbleSOS
//
//  Created by Sally Yang Jing Ou on 2015-04-30.
//  Copyright (c) 2015 Sally Yang Jing Ou. All rights reserved.
//

#import "WhatIsPebbleSOSViewController.h"

@interface WhatIsPebbleSOSViewController ()
@property (weak, nonatomic) IBOutlet UIButton *gotItButton;

@end

@implementation WhatIsPebbleSOSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
