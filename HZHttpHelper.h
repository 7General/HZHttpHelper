//
//  HZHttpHelper.h
//
//
//  Created by wanghuizhou on
//  Copyright (c) 2015年 Beijing . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"


typedef enum  {
    checkNetWorkStateUnknown = 0,   // 没有网络
    checkNetWorkStateReachable ,     // 没有网络
    checkNetWorkStateViaWWAN ,       // 手机自带网络
    checkNetWorkStateWiFi,                    // WIFI状态
} NetWorkState;



typedef void (^readOldData)();

typedef void (^successBlock)(id responseObject);
typedef void (^failureBlock)(NSError *error);

typedef void (^NetWorkStateReachable)(NetWorkState typesState);


@interface HZHttpHelper : NSObject



@property (nonatomic, assign)NetWorkState  StateType;

/**
 *  创建单例
 *
 *  @return 单例的类方法
 */
+ (HZHttpHelper *)defaultManager;
/**
 *  由用户发送的请求(首先确定在viewwillAppear时 初始化该单例对象)
 *
 *  @param requstString                请求内容
 *  @param parameters                传送内容
 *  @param readOldData            开始读取旧数据
 *  @param success                       开始网络请求读取新数据
 *  @param failure                          请求数据失败
 *  @param checkNetWorkDo   没有网络时dosomthing
  *  @param isReadLoadData    没有网络时是否请求上次旧数据 YES 为请求网络数据   NO 为不请求网络
 */
- (void)requestHttpByUserWithString:(NSString *)requstString
                                  parameters:(NSDictionary *)parameters
                                         success:(successBlock)success
                                            failure:(failureBlock)failure
                             NetWorkState:(NetWorkStateReachable)checkNetWorkDo
                     isLoadViewData:(BOOL)isReadLoadData;





/**
 *  (******网络状态程序中延迟获取)
 *  进入控制器自动发起数据请求(**********用于程序首次加载数据)，
 *  先读取缓存数据，
 *  等新数据读取完成之后在更新界面
 *
 *  @param requstString   请求内容
 *  @param parameters     传送内容
 *  @param beforeData     读取上次数据
 *  @param success        开始网络请求读取新数据
 *  @param failure        请求数据失败
 *  @param checkNetWorkDo 没有网络时dosomthing
 */
- (void)autoFirstRequestHttpWithString:(NSString *)requstString
                            parameters:(NSDictionary *)parameters
                               success:(successBlock)success
                               failure:(failureBlock)failure
                          NetWorkState:(NetWorkStateReachable)checkNetWorkDo;



/**
 *  (******网络状态已经获取)
 *  进入控制器自动发起数据请求
 *
 *  @param requstString   请求内容
 *  @param parameters     传送内容
 *  @param success        开始网络请求读取新数据
 *  @param failure        请求数据失败
 *  @param checkNetWorkDo 没有网络时dosomthing
 */
- (void)autoRequestHttpWithNetStateWithString:(NSString *)requstString
                            parameters:(NSDictionary *)parameters
                               success:(successBlock)success
                               failure:(failureBlock)failure
                          NetWorkState:(NetWorkStateReachable)checkNetWorkDo;




@end
