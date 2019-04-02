//
//  ViewController.m
//  Devtest
//
//  Created by 张超 on 2019/3/30.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "ViewController.h"
#import "AppleAPIHelper.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)change:(id)sender {
    [AppleAPIHelper setIconname:@"icon1"];
}

@end
