//
//  ZMUserCenterViewController.m
//  ZMRouter_Example
//
//  Created by Zhimi on 2020/5/11.
//  Copyright © 2020 hexuren. All rights reserved.
//

#import "ZMUserCenterViewController.h"
#import "ZMRouter.h"

@interface ZMUserCenterViewController ()

@end

@implementation ZMUserCenterViewController

/// 需要登录
-(BOOL)zm_routerNeedLogin{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor redColor];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
