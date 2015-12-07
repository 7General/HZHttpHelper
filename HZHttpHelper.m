//
//  HZHttpHelper.m
//
//
//  Created by wanghuizhou on 15/5/14.
//  Copyright (c) 2015年 Beijing All rights reserved.
//

#import "HZHttpHelper.h"
#import "HZConfigManager.h"

@implementation HZHttpHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self CheckNetworkState];
    }
    return self;
}


+ (HZHttpHelper *)defaultManager
{
    static HZHttpHelper * s_defaultManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_defaultManager = [[HZHttpHelper alloc] init];
    });
    
    return s_defaultManager;
}




- (void)requestHttpByUserWithString:(NSString *)               requstString
                                            parameters:(NSDictionary *)      parameters
                                                   success:(successBlock)         success
                                                      failure:(failureBlock)            failure
                                       NetWorkState:(NetWorkStateReachable)checkNetWorkDo
                                  isLoadViewData:(BOOL)isReadLoadData
{
    

    // 1.创建网络请求管理者
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 10.f;
    NSDictionary *requestDic =[HZConfigManager requestDicWithString:requstString];
    //NSString * urls = @"http://open.qyer.com/qyer/bbs/forum_thread_list?client_id=qyer_android&client_secret=9fcaae8aefc4f9ac4915&forum_id=3&forum_type=6&count=10&page=1&delcache=0";
    //NSDictionary *requestDic =@{@"url":urls,@"method":@"GET"};
    NSString *url =[requestDic objectForKey:@"url"];
    NSString *method =[requestDic objectForKey:@"method"];
    
    //判断网络
    if (self.StateType == checkNetWorkStateReachable || self.StateType == checkNetWorkStateUnknown) {
        
        BOOL FlagReadData = NO;
        FlagReadData = isReadLoadData;
        
        if (isReadLoadData) {
            if (checkNetWorkDo) {
                checkNetWorkDo(self.StateType);
            }
        }
       
        return;
    }
    
    
    if ([method isEqualToString:@"GET"]) {
        [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if (success) {
                success(responseObject);
            }
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            if ([operation.response statusCode] == 401) {
                NSLog(@"401错误");
            }
            if (failure) {
                failure(error);
            }
        }];
    }
    else {
        // 2.发送网络请求请求数据
        [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             if (success) {
                 success(responseObject);
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if ([operation.response statusCode] == 401) {
                 NSLog(@"401错误");
             }
             if (failure) {
                 failure(error);
             }
         }];
    }
    
}
//- (void)autoRequestHttpWithString:(NSString *)requstString
//                             parameters:(NSDictionary *)parameters
//                                success:(successBlock)success
//                                failure:(failureBlock)failure
//                           NetWorkState:(NetWorkStateReachable)checkNetWorkDo {
//   
//    //在没成功请求以前读取旧数据
//    if (checkNetWorkDo) {
//        checkNetWorkDo(10);
//    }
//    [self requestHttpByUserWithString:requstString parameters:parameters success:success failure:failure NetWorkState:checkNetWorkDo isLoadViewData:NO];
//
//}

- (void)autoFirstRequestHttpWithString:(NSString *)requstString
                       parameters:(NSDictionary *)parameters
                          success:(successBlock)success
                          failure:(failureBlock)failure
                     NetWorkState:(NetWorkStateReachable)checkNetWorkDo
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        __weak typeof(self) weakself = self;
        [weakself CheckNetworkState];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
            //在没成功请求以前读取旧数据
            if (checkNetWorkDo) {
                checkNetWorkDo(10);
            }
            [self requestHttpByUserWithString:requstString parameters:parameters success:success failure:failure NetWorkState:checkNetWorkDo isLoadViewData:YES];
        });
    });
    
}






- (void)autoRequestHttpWithNetStateWithString:(NSString *)requstString
                                   parameters:(NSDictionary *)parameters
                                      success:(successBlock)success
                                      failure:(failureBlock)failure
                                 NetWorkState:(NetWorkStateReachable)checkNetWorkDo {

    [self requestHttpByUserWithString:requstString parameters:parameters success:success failure:failure NetWorkState:checkNetWorkDo isLoadViewData:YES];
}


- (void)CheckNetworkState
{
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    // 2.设置网络状态改变后的处理
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
            {
                NSLog(@"----:未知网络");
                self.StateType = checkNetWorkStateUnknown;
            }
                break;
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
            {
                NSLog(@"----:没有网络(断网)");
                self.StateType = checkNetWorkStateReachable;
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
            {
                NSLog(@"----:手机自带网络");
                self.StateType = checkNetWorkStateViaWWAN;
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
            {
                NSLog(@"----:WIFI");
                self.StateType = checkNetWorkStateWiFi;
            }
                break;
            default:
                break;
        }
    }];
    [mgr startMonitoring];
}






@end
