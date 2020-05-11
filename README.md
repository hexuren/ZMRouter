# ZMRouter

[![CI Status](https://img.shields.io/travis/hexuren/ZMRouter.svg?style=flat)](https://travis-ci.org/hexuren/ZMRouter)
[![Version](https://img.shields.io/cocoapods/v/ZMRouter.svg?style=flat)](https://cocoapods.org/pods/ZMRouter)
[![License](MIT)
[![Platform](ios)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

ZMRouter is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ZMRouter'
```

## Author

hexuren, 529455009@qq.com

## License

ZMRouter is available under the MIT license. See the LICENSE file for more info.

## How to use

> 将界面的跳转操作都放在一个地方统一处理
> 不用关心当前控制器是什么，不用繁琐的引用文件，
> 将各模块之间隔离开来
> 接收参数的属性不需要暴露在h文件中

### 用途
通过控制器的 类名字符串 来索引 打开该控制器

### 路由支持
- push
- present
- push storyboard的vc
- present storyboard的vc
- scheme 链接打开vc
- link 链接打开vc
- 参数传递
- 数据回调上一个界面
- 登录状态判断
- 同一个界面是刷新还是重新打开
- 控制器映射表

### 实现
##### 初始配置
```
    ZMRouter * router = [ZMRouter sharedRouter];
    router.url_scheme = @"ZMRouter";
    打开链接 可通过该key查找控制器名字 如果为空取链接的host信息
    router.linkURLPageKey = @"page";
    present出来的vc加载在该控制器上
    router.presentNavcClass = [ZMBaseNavigationViewController class];
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
    
    //key是控制器的名字 如果是Storyboard 带上SB的名字 
    //value 可以是字符串 可以是 number类型 可以是包含字符串和number的数组
    [router addMapperDic:@{
        @"ZMColorViewController":@"color",
        @"ZMScrollViewController":@(1000),
        @"ZMTableViewController":@[@"table",@(1001)],
        @"ZMDetailsViewController":@[@"detail",@(1002)],
        @"ZMOrderViewController":@"order",
        @"Main.ZMDebugSBViewController":@"debug"
    }];
```

##### Push
```
[ZMRouter zm_pushVCName:@"ZMColorViewController"]
[ZMRouter zm_pushVCName:@"Main.ZMDebugSBViewController"]
```
#### Present
```
[ZMRouter zm_presentVCName:@"ZMTableViewController"]
[ZMRouter zm_presentVCName:@"Main.ZMDebugSBViewController"]
```
#### Scheme
```
[ZMRouter zm_openSchemeURL:@"ZMRouter://detail?id=12&type=22"].
```
#### Link
```
[ZMRouter zm_openLinkURL:@"https://order?orderID=10086"].
```
####  参数传递 及回调
```
[ZMRouter zm_pushVCName:@"order"
                         params:@{@"orderID":@(8888)}
                      callBlock:^(id  _Nullable passResult) {
            NSLog(@"%@",passResult);
        }]

回调
if(self.routerCallBlock){
        self.routerCallBlock([NSString stringWithFormat:@"call back other order ID: %zd",self.orderID]);
    }
```

---
## 控制器中ZMRouterProtocol设置
#### 接收参数
```
- (void)zm_routerPassParamViewController:(id)parameters;
```
####  该页面是否要显示 将要显示控制器 配置参数
比如：如果当前再订单详情页 当前订单界面是否刷新还是再叠加一个新的界面
```
- (BOOL)zm_routerReloadViewController_shoudShowNext:(id)parameters;
```
####  是否需要登录
```
- (BOOL)zm_routerNeedLogin;
```
例子：
```
-(void)zm_routerPassParamViewController:(id)parameters{
    NSLog(@"接收到的参数 ： %@",parameters);
    
    if([parameters isKindOfClass:[NSDictionary class]] &&
       parameters[@"orderID"]){
        self.orderID = [parameters[@"orderID"] integerValue];
    }
}

- (BOOL)zm_routerReloadViewController_shoudShowNext:(id)parameters{
    if([parameters isKindOfClass:[NSDictionary class]] &&
       parameters[@"orderID"]){
        NSInteger orderID = [parameters[@"orderID"] integerValue];
        if(orderID == self.orderID){
            NSLog(@"同样的订单ID 刷新当前界面");
            return NO;
        }
    }
    return YES;
}

....
..
.

- (void)pushEvent{
    
    __weak typeof(&*self)weakSelf = self;
    
    [ZMRouter zm_pushVCName:@"order"
                     params:@{@"orderID":@(arc4random()%1000+1000)}
                  callBlock:^(id  _Nullable passResult) {
        
        self.orderInfo.text = [NSString stringWithFormat:@"%@\n%@",passResult,@(weakSelf.orderID).stringValue];
    }];
}

- (void)sameEvent{
    
    __weak typeof(&*self)weakSelf = self;
    
    [ZMRouter zm_pushVCName:@"order"
                     params:@{@"orderID":@(self.orderID)}
                  callBlock:^(id  _Nullable passResult) {
        
        self.orderInfo.text = [NSString stringWithFormat:@"%@\n%@",passResult,@(weakSelf.orderID).stringValue];
    }];
}

- (void)callbackEvent{
    
    if(self.routerCallBlock){
        self.routerCallBlock([NSString stringWithFormat:@"call back other order ID: %zd",self.orderID]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
```



