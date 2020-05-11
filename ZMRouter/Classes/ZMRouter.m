//
//  ZMRouter.m
//  ZMRouter
//
//  Created by Zhimi on 2020/5/11.
//

#import "ZMRouter.h"
#import <objc/runtime.h>

#define ZMRouterLog(format, ...) NSLog((@"ZMRouter >>> " format), ##__VA_ARGS__)

#pragma mark - UINavigationController+ZMRouter


UIViewController * ZMCurrentViewController(void){
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[UITabBarController class]]) {
        result = [(UITabBarController *)result selectedViewController];
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result topViewController];
    }
    return result;
}

BOOL IsNull(id obj){
    if(!obj){
        return YES;
    }
    if(obj == nil || [obj isEqual:[NSNull class]] || [obj isKindOfClass:[NSNull class]]){
        return YES;
    }
    if([obj isKindOfClass:[NSString class]]){
        NSString * str = (NSString *)obj;
        if([str isEqualToString:@""]){
            return YES;
        }
        if ([[str stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]){
            return YES;
        }
    }
    return NO;
}

void ZMRouter_swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


@interface UINavigationController (ZMRouter)

@end

@implementation UINavigationController (ZMRouter)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ZMRouter_swizzleMethod(class, @selector(viewWillAppear:), @selector(router_navigationViewWillAppear:));
    });
}

- (void)router_navigationViewWillAppear:(BOOL)animation {
    [self router_navigationViewWillAppear:animation];
    
    if([ZMRouter sharedRouter].currentNavigationController){
        [[ZMRouter sharedRouter] setValue:[ZMRouter sharedRouter].currentNavigationController forKey:@"preNavc"];
    }
    [ZMRouter sharedRouter].currentNavigationController = self;
    
}


@end



@implementation UIViewController(ZMRouter)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        ZMRouter_swizzleMethod(class, @selector(viewWillAppear:), @selector(router_ViewWillAppear:));
    });
}

- (void)router_ViewWillAppear:(BOOL)animation {
    [self router_ViewWillAppear:animation];
    
    if(self.navigationController){
        if([ZMRouter sharedRouter].currentNavigationController){
            [[ZMRouter sharedRouter] setValue:[ZMRouter sharedRouter].currentNavigationController forKey:@"preNavc"];
        }
        [ZMRouter sharedRouter].currentNavigationController = self.navigationController;
    }
}

- (ZMRouterCallBlock)routerCallBlock{
    return objc_getAssociatedObject(self, @selector(routerCallBlock));
}

-(void)setRouterCallBlock:(ZMRouterCallBlock)routerCallBlock{
    objc_setAssociatedObject(self, @selector(routerCallBlock), routerCallBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end






#pragma mark - ZMRouter

@interface ZMRouter()

@property (weak, nonatomic) UINavigationController * preNavc;

@property (retain, nonatomic) NSMutableDictionary <NSString *, id> * mapper;

@end


@implementation ZMRouter


+ (instancetype)sharedRouter {
    static ZMRouter *router = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (!router) {
            router = [[ZMRouter alloc] init];
            router.url_scheme = @"";
            router.mapper = [NSMutableDictionary new];
        }
    });
    return router;
}

- (UIViewController *)currentViewController{
    return ZMCurrentViewController();
}

/// 跳转控制器映射
- (void)addMapperVC:(NSString *)vcName mapKey:(id)mapKey{
    if(IsNull(vcName) || IsNull(mapKey)){
        return;
    }
    self.mapper[vcName] = mapKey;
}
- (void)addMapperDic:(NSDictionary<NSString *, id> *)mapperDic{
    [self.mapper addEntriesFromDictionary:mapperDic];
}

#pragma mark - key mapper

- (NSString *)mapperController:(NSString *)mapper{
    
    __block NSString * reslutMapper = mapper;
    
    NSDictionary * customMapper = self.mapper;
    [customMapper enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, NSString *mappedToKey, BOOL *stop) {

        if ([mappedToKey isKindOfClass:[NSString class]]) {
            
            if([mappedToKey isEqualToString:mapper]){
                reslutMapper = propertyName;
                return;
            }
            
        } else if ([mappedToKey isKindOfClass:[NSArray class]]) {

            for (NSString *oneKey in ((NSArray *)mappedToKey)) {
                if([oneKey isKindOfClass:[NSString class]]){
                    if([oneKey isEqualToString:mapper]){
                        reslutMapper = propertyName;
                        return;
                    }
                }else if ([oneKey isKindOfClass:[NSNumber class]]){
                    NSNumber * oneKeyNum = (NSNumber *)oneKey;
                    if([oneKeyNum.stringValue isEqualToString:mapper]){
                        reslutMapper = propertyName;
                        return;
                    }
                }
            }
        }
    }];
    
    return reslutMapper;
}


#pragma mark -



//=================== Push

+ (UIViewController *)zm_pushVCName:(NSString *)vcName{
    
    return [ZMRouter zm_pushVCName:vcName params:nil callBlock:nil];
}

+ (UIViewController *)zm_pushVCName:(NSString *)vcName params:(id)passParams callBlock:(ZMRouterCallBlock)callBlock{
    if(vcName && vcName.length > 0){
        UIViewController * vc = [[ZMRouter sharedRouter] zm_getControllerByVCName:vcName queryParams:passParams];
        vc.routerCallBlock = callBlock;
        if (!vc) {
            ZMRouterLog(@"没有 实现 %@",vcName);
            return nil;
        }
        
        void (^push)(void) = ^void () {
            ZMRouter * router = [ZMRouter sharedRouter];
            if(router.currentNavigationController){
                [router.currentNavigationController pushViewController:vc animated:YES];
            }else if ([router valueForKey:@"preNavc"]){
                UINavigationController * navc = [router valueForKey:@"preNavc"];
                [navc pushViewController:vc animated:YES];
            }else if (router.currentViewController.navigationController){
                UINavigationController * navc = router.currentViewController.navigationController;
                [navc pushViewController:vc animated:YES];
            } else{
                ZMRouterLog(@"没有找到导航控制器");
            }
        };
        SEL selectorLogin = NSSelectorFromString(@"zm_routerNeedLogin");
        if([vc respondsToSelector:selectorLogin]){
            BOOL needLogin = [vc zm_routerNeedLogin];
            
            if (needLogin &&
                [ZMRouter sharedRouter].needLoginBlock &&
                ![ZMRouter sharedRouter].needLoginBlock()) {
                
                return vc;
            }
        }
        push();
        
        return vc;
    }else{
        ZMRouterLog(@"没有控制器 %@ 的实现",vcName);
        return nil;
    }
}

+ (UIViewController *)zm_presentVCName:(NSString *)vcName{
    return [ZMRouter zm_presentVCName:vcName params:nil callBlock:nil];
}

+ (UIViewController *)zm_presentVCName:(NSString *)vcName params:(id)passParams callBlock:(ZMRouterCallBlock)callBlock{

    if(vcName && vcName.length > 0){
        
        ZMRouter * router = [ZMRouter sharedRouter];
        
        UIViewController * vc = [router zm_getControllerByVCName:vcName queryParams:passParams];
        vc.routerCallBlock = callBlock;
        
        UINavigationController * navc;
        if(router.presentNavcClass &&
           [router.presentNavcClass isSubclassOfClass:[UINavigationController class]]
           ){
            navc = [router.presentNavcClass new];
        }else{
            navc = [UINavigationController new];
        }
        [navc setViewControllers:@[vc] animated:NO];
        
        if(router.currentNavigationController){
            [router.currentNavigationController presentViewController:navc animated:YES completion:nil];
        }else{
            [router.currentViewController presentViewController:navc animated:YES completion:nil];
        }

        return vc;
    }else{
        ZMRouterLog(@"没有控制器 %@ 的实现",vcName);
        return nil;
    }
}


#pragma mark - URL route

/** 通过URL跳转 内部含 控制器名称的参数信息*/
+ (UIViewController *)zm_openSchemeURL:(NSString *)routePattern{

    NSURLComponents *components = [NSURLComponents componentsWithString:routePattern];
    NSString *scheme = components.scheme;
    
    //scheme规则自己添加
    if([ZMRouter sharedRouter].url_scheme){
        if (![scheme isEqualToString:[ZMRouter sharedRouter].url_scheme]) {
            ZMRouterLog(@"scheme规则不匹配");
            return nil;
        }
    }
    
    NSString * vcHost = nil;
    
    if (components.host.length > 0 && (![components.host isEqualToString:@"localhost"] && [components.host rangeOfString:@"."].location == NSNotFound)) {
        vcHost = [components.percentEncodedHost copy];
        components.host = @"/";
        components.percentEncodedPath = [vcHost stringByAppendingPathComponent:(components.percentEncodedPath ?: @"")];
    }
    
    NSString *path = [components percentEncodedPath];
    
    if (components.fragment != nil) {
        BOOL fragmentContainsQueryParams = NO;
        NSURLComponents *fragmentComponents = [NSURLComponents componentsWithString:components.percentEncodedFragment];
        
        if (fragmentComponents.query == nil && fragmentComponents.path != nil) {
            fragmentComponents.query = fragmentComponents.path;
        }
        
        if (fragmentComponents.queryItems.count > 0) {
            fragmentContainsQueryParams = fragmentComponents.queryItems.firstObject.value.length > 0;
        }
        
        if (fragmentContainsQueryParams) {
            components.queryItems = [(components.queryItems ?: @[]) arrayByAddingObjectsFromArray:fragmentComponents.queryItems];
        }
        
        if (fragmentComponents.path != nil && (!fragmentContainsQueryParams || ![fragmentComponents.path isEqualToString:fragmentComponents.query])) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"#%@", fragmentComponents.percentEncodedPath]];
        }
    }
    
    if (path.length > 0 && [path characterAtIndex:0] == '/') {
        path = [path substringFromIndex:1];
    }
    
    if (path.length > 0 && [path characterAtIndex:path.length - 1] == '/') {
        path = [path substringToIndex:path.length - 1];
    }
    
    //获取queryItem
    NSArray <NSURLQueryItem *> *queryItems = [components queryItems] ?: @[];
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];
    for (NSURLQueryItem *item in queryItems) {
        if (item.value == nil) {
            continue;
        }
        
        if (queryParams[item.name] == nil) {
            queryParams[item.name] = item.value;
        } else if ([queryParams[item.name] isKindOfClass:[NSArray class]]) {
            NSArray *values = (NSArray *)(queryParams[item.name]);
            queryParams[item.name] = [values arrayByAddingObject:item.value];
        } else {
            id existingValue = queryParams[item.name];
            queryParams[item.name] = @[existingValue, item.value];
        }
    }
    
    NSDictionary *params = queryParams.copy;
    if(!vcHost && [params isKindOfClass:[NSDictionary class]]){
        vcHost = params[@"vc"];
    }
    
    //判断是否需要单独处理
    if([ZMRouter sharedRouter].URLOpenHostContinuePushBlock){
        BOOL continuePush = [ZMRouter sharedRouter].URLOpenHostContinuePushBlock(vcHost, params);
        if(!continuePush){
            return nil;
        }
    }
    
    return [ZMRouter zm_pushVCName:vcHost params:params callBlock:nil];
}

/** 通过URL跳转 内部含 控制器名称的参数信息*/
+ (UIViewController *)zm_openLinkURL:(NSString *)routePattern {

    NSURLComponents *components = [NSURLComponents componentsWithString:routePattern];
    
    //获取queryItem
    NSArray <NSURLQueryItem *> *queryItems = [components queryItems] ?: @[];
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];
    for (NSURLQueryItem *item in queryItems) {
        if (item.value == nil) {
            continue;
        }
        
        if (queryParams[item.name] == nil) {
            queryParams[item.name] = item.value;
        } else if ([queryParams[item.name] isKindOfClass:[NSArray class]]) {
            NSArray *values = (NSArray *)(queryParams[item.name]);
            queryParams[item.name] = [values arrayByAddingObject:item.value];
        } else {
            id existingValue = queryParams[item.name];
            queryParams[item.name] = @[existingValue, item.value];
        }
    }
    
    NSDictionary *params = queryParams.copy;
    
    NSString * page = nil;
    if (components.host.length > 0 && (![components.host isEqualToString:@"localhost"] && [components.host rangeOfString:@"."].location == NSNotFound)) {
        page = [components.percentEncodedHost copy];
    }
    
    NSString * pageKey = [ZMRouter sharedRouter].linkURLPageKey;
    if([params isKindOfClass:[NSDictionary class]] &&
       pageKey &&
       [params objectForKey:pageKey]){
        page = params[pageKey];
    }
    if (IsNull(page)) {
        page = [components.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    }
    
    //判断是否需要单独处理
    if([ZMRouter sharedRouter].URLOpenHostContinuePushBlock){
        BOOL continuePush = [ZMRouter sharedRouter].URLOpenHostContinuePushBlock(page, params);
        if(!continuePush){
            return nil;
        }
    }
    
    return [ZMRouter zm_pushVCName:page params:params callBlock:nil];
}


#pragma mark - privite
//界面跳转
- (UIViewController *)zm_getControllerByVCName:(NSString *)targetName queryParams:(NSDictionary *)queryParams {
    if(!targetName || targetName.length == 0){
        return nil;
    }

    targetName = [self mapperController:targetName];
    NSString * sbName = nil;
    NSString * vcName = targetName;
    if([targetName containsString:@"."]){
        sbName = [targetName componentsSeparatedByString:@"."].firstObject;
        vcName = [targetName componentsSeparatedByString:@"."].lastObject;
    }
    Class vcClass = NSClassFromString(vcName);
    if(!vcClass){
        ZMRouterLog(@"没有控制器 %@ 的实现",vcName);
        return nil;
    }
    //是同一个控制器
    UIViewController * currentVC = [[ZMRouter sharedRouter] currentViewController];
    if([currentVC isKindOfClass:vcClass]){
        SEL selectorShow = NSSelectorFromString(@"zm_routerReloadViewController_shoudShowNext:");
        if([currentVC respondsToSelector:selectorShow]){
            if(![currentVC zm_routerReloadViewController_shoudShowNext:queryParams]){
                //不做跳转
                ZMRouterLog(@"同一个控制器 %@ 不做跳转 刷新当前界面",vcName);
                return nil;
            }
        }
    }
    
    SEL selectorCreate = NSSelectorFromString(@"zm_routerCreateViewController:");
    UIViewController *targetController;
    if(sbName){
        targetController = [[UIStoryboard storyboardWithName:sbName bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:vcName];
        if(!targetController){
            ZMRouterLog(@"在 storyboard %@ 中没有找到该控制器 %@ ",sbName,vcName);
            return nil;
        }
        if(queryParams){
            SEL selectorConfig = NSSelectorFromString(@"zm_routerPassParamViewController:");
            if([targetController respondsToSelector:selectorConfig]){
                [targetController zm_routerPassParamViewController:queryParams];
            }
        }
    }else{
        if ([vcClass respondsToSelector:selectorCreate]) {
            targetController = [vcClass zm_routerCreateViewController:queryParams];
        }else{
            targetController = [vcClass new];
            
            if(queryParams){
                SEL selectorConfig = NSSelectorFromString(@"zm_routerPassParamViewController:");
                if([targetController respondsToSelector:selectorConfig]){
                    [targetController zm_routerPassParamViewController:queryParams];
                }
            }
        }
    }
    
    if(![targetController isKindOfClass:[UIViewController class]]){
        ZMRouterLog(@"不是控制器 %@ ",targetName);
        return nil;
    }
    
    return targetController;
}

@end
