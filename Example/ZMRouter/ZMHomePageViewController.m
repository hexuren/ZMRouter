//
//  ZMHomePageViewController.m
//  ZMRouter_Example
//
//  Created by Zhimi on 2020/5/11.
//  Copyright © 2020 hexuren. All rights reserved.
//

#import "ZMHomePageViewController.h"
#import "ZMBaseNavigationController.h"
#import "ZMRouter.h"

@interface ZMCellItem : NSObject

@property (copy, nonatomic) NSString * title;
@property (copy, nonatomic) NSString * subTitle;
/// cell点击
@property (copy, nonatomic) void(^clickBlock)(__kindof ZMCellItem * passItem);

@end

@implementation ZMCellItem

@end

@interface ZMHomePageViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) UITableView * tableView;

@property (retain, nonatomic) NSMutableArray <ZMCellItem *>* dataList;

@end

@implementation ZMHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"ZMRouter路由跳转";
    [self.navigationController.navigationBar setTranslucent:NO];
    
    
    /// - ZMRouter 配置
    ZMRouter * router = [ZMRouter sharedRouter];
    router.url_scheme = @"ZMRouter";
    router.linkURLPageKey = @"page";
    router.presentNavcClass = [ZMBaseNavigationController class];
    [router setNeedLoginBlock:^BOOL{
        NSLog(@"做登录判断, 未登录去做登录操作, 这里返回YES表示 已登录");
        
        return YES;
    }];
    //外部链接打开 判断是否单独做处理 YES继续下一步跳转处理
    [router setURLOpenHostContinuePushBlock:^BOOL(NSString * _Nonnull vchost, NSDictionary * _Nonnull params) {
        if([vchost isEqualToString:@"tabbar"]){
            NSLog(@"假设是tabbar 标签栏切换操作 不做下一步处理 : %@",params);
            return NO;
        }
        return YES;
    }];
    
    [router addMapperDic:@{
        @"ZMColorViewController":@"color",
        @"ZMScrollViewController":@(1000),
        @"ZMTableViewController":@[@"table",@(1001)],
        @"ZMDetailsViewController":@[@"detail",@(1002)],
        @"ZMOrderViewController":@"order",
        @"Main.ZMDebugSBViewController":@"debug"
    }];
    
    /// -
    
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 50;
    [self.view addSubview:self.tableView];
    
    self.dataList = [NSMutableArray new];
    
    ZMCellItem * item = [ZMCellItem new];
    item.title = @"Push - vc";
    [item setClickBlock:^(__kindof ZMCellItem *passItem) {
        [ZMRouter zm_pushVCName:@"ZMColorViewController"].
        title = passItem.title;
    }];
    [self.dataList addObject:item];
    
    item = [ZMCellItem new];
    item.title = @"Push - vc from storyboard";
    [item setClickBlock:^(__kindof ZMCellItem *passItem) {
        [ZMRouter zm_pushVCName:@"Main.ZMDebugSBViewController"].
        title = passItem.title;
    }];
    [self.dataList addObject:item];
    
    item = [ZMCellItem new];
    item.title = @"Present - vc";
    [item setClickBlock:^(__kindof ZMCellItem *passItem) {
        [ZMRouter zm_presentVCName:@"ZMTableViewController"].
        title = passItem.title;
    }];
    [self.dataList addObject:item];
    
    item = [ZMCellItem new];
    item.title = @"Present - vc from storyboard";
    [item setClickBlock:^(__kindof ZMCellItem *passItem) {
        [ZMRouter zm_presentVCName:@"Main.ZMDebugSBViewController"].
        title = passItem.title;
    }];
    [self.dataList addObject:item];
    
    item = [ZMCellItem new];
    item.title = @"Scheme link open";
    [item setClickBlock:^(__kindof ZMCellItem *passItem) {
        [ZMRouter zm_openSchemeURL:@"ZMRouter://detail?id=12&type=22"].
        title = passItem.title;
    }];
    [self.dataList addObject:item];
    
    item = [ZMCellItem new];
    item.title = @"Scheme tabbar select change";
    [item setClickBlock:^(__kindof ZMCellItem *passItem) {
        [ZMRouter zm_openSchemeURL:@"ZMRouter://tabbar?index=2"].
        title = passItem.title;
    }];
    [self.dataList addObject:item];
    
    item = [ZMCellItem new];
    item.title = @"URL link open test 1";
    [item setClickBlock:^(__kindof ZMCellItem *passItem) {
        [ZMRouter zm_openLinkURL:@"https://1002?orderID=10086"].
        title = passItem.title;
    }];
    [self.dataList addObject:item];
    
    item = [ZMCellItem new];
    item.title = @"URL link open test 2";
    [item setClickBlock:^(__kindof ZMCellItem *passItem) {
        [ZMRouter zm_openLinkURL:@"https://haha?orderID=10010&page=detail"].
        title = passItem.title;
    }];
    [self.dataList addObject:item];
    
    //参数传递
    item = [ZMCellItem new];
    item.title = @"parameter passing";
    [item setClickBlock:^(__kindof ZMCellItem *passItem) {
        [ZMRouter zm_pushVCName:@"order"
                         params:@{@"orderID":@(9999)}
                      callBlock:nil].
                      title = passItem.title;
    }];
    [self.dataList addObject:item];
    
    item = [ZMCellItem new];
    item.title = @"call back";
    [item setClickBlock:^(__kindof ZMCellItem *passItem) {
        [ZMRouter zm_pushVCName:@"order"
                         params:@{@"orderID":@(8888)}
                      callBlock:^(id  _Nullable passResult) {
            NSLog(@"%@",passResult);
        }].
        title = passItem.title;
    }];
    [self.dataList addObject:item];
    
    item = [ZMCellItem new];
    item.title = @"need login in first";
    [item setClickBlock:^(__kindof ZMCellItem *passItem) {
        [ZMRouter zm_pushVCName:@"ZMUserCenterViewController"].
        title = passItem.title;
    }];
    [self.dataList addObject:item];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifyPage"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"CellIdentifyPage"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%zd: %@",indexPath.row+1,self.dataList[indexPath.row].title];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZMCellItem * item = self.dataList[indexPath.row];
    
    if(item.clickBlock){
        item.clickBlock(item);
    }
}

@end
