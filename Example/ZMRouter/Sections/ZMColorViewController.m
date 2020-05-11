//
//  ZMColorViewController.m
//  ZMRouter_Example
//
//  Created by Zhimi on 2020/5/11.
//  Copyright © 2020 hexuren. All rights reserved.
//

#import "ZMColorViewController.h"

@interface ZMColorViewController ()

@end

@implementation ZMColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1];
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
