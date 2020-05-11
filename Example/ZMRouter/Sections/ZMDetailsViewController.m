//
//  ZMDetailsViewController.m
//  ZMRouter_Example
//
//  Created by Zhimi on 2020/5/11.
//  Copyright © 2020 hexuren. All rights reserved.
//

#import "ZMDetailsViewController.h"
#import "ZMRouter.h"

@interface ZMDetailsViewController ()

@end

@implementation ZMDetailsViewController

-(void)zm_routerPassParamViewController:(id)parameters{
    
    NSLog(@"接收到的参数 信息 是 : %@", parameters);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blueColor];
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
