//
//  ZMScrollViewController.m
//  ZMRouter_Example
//
//  Created by Zhimi on 2020/5/11.
//  Copyright © 2020 hexuren. All rights reserved.
//

#import "ZMScrollViewController.h"
#import "Masonry.h"

@interface ZMScrollViewController ()

@property (retain, nonatomic) UIScrollView * scrollView;

@end

@implementation ZMScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scrollView = [UIScrollView new];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
        
    for(NSInteger i = 0; i<20; i++){
        UIView * subV = [self createLab];
        [self.scrollView addSubview:subV];
    }
    
    [self.scrollView.subviews mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:50 leadSpacing:50 tailSpacing:50];
    [self.scrollView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
}

- (UILabel *)createLab{
    
    UILabel * lab = [UILabel new];
    lab.backgroundColor = [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1];
    lab.text = [NSString stringWithFormat:@"\n%@\n",@(arc4random()%10000+1000).stringValue];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.numberOfLines = 0;
    lab.font = [UIFont systemFontOfSize:30];
    lab.textColor = [UIColor whiteColor];

    return lab;
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
