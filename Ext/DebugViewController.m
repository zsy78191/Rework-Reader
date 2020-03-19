//
//  DebugViewController.m
//  rework-reader
//
//  Created by 张超 on 2019/11/25.
//  Copyright © 2019 orzer. All rights reserved.
//

#import "DebugViewController.h"

@interface DebugViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *sw;
@property (weak, nonatomic) IBOutlet UIButton *bt;

@end

@implementation DebugViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.bt.hidden = self.hideFirst;
    
    BOOL report = [[NSUserDefaults standardUserDefaults] boolForKey:@"kReport"];
    
    self.sw.on = report;
    [self.sw addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventValueChanged];
}

- (void)toggle:(UISwitch*)s
{
    BOOL on = s.on;
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:@"kReport"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)action1:(UIButton*)sender {
    [sender setEnabled:NO];
    if (self.actionBlock) {
        self.actionBlock(0);
    }
}
- (IBAction)action2:(UIButton*)sender {
    [sender setEnabled:NO];
    if (self.actionBlock) {
        self.actionBlock(1);
    }
}
- (IBAction)action3:(UIButton*)sender {
    [sender setEnabled:NO];
    if (self.actionBlock) {
        self.actionBlock(2);
    }
}

@end
