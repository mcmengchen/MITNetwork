//
//  MITNetworkEngine.h
//  Pods
//
//  Created by MENGCHEN on 2017/3/7.
//
//

#import <Foundation/Foundation.h>
#import "MITNetworkConfig.h"



@class MITNetworkRequest;


NS_ASSUME_NONNULL_BEGIN
@interface MITNetworkEngine : NSObject



// 不可用
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;


+ (nullable MITNetworkEngine *)defaultEngine;



//发送请求
+ (MITNetworkRequest *)sendRequest:(nullable MITRequestBlock)requestBlock
                onSuccess:(nullable MITSuccessBlock)successBlock
                onFailure:(nullable MITFailureBlock)failureBlock;

+ (MITNetworkRequest *)sendRequest:(nullable MITRequestBlock)requestBlock
               onProgress:(nullable MITProgressBlock)progressBlock
                onSuccess:(nullable MITSuccessBlock)successBlock
                onFailure:(nullable MITSuccessBlock)failureBlock;

//取消请求
+ (void)cancelRequest:(MITNetworkRequest * )request Block:(void(^)(BOOL,MITNET_REQUEST_STEP))cancelBlock;
//暂停
+ (void)suspend:(MITNetworkRequest *)request;
//继续
+ (void)resume:(MITNetworkRequest *)request;
//取消所有请求
+ (void)cancelAllRequest;

//获取当前网络状态
+ (MITNET_REACHABILITY_TATUS)getCurrentNetStatus;

//设置网络变化回调
+ (void)setNetStatusChangeCallBack:(void(^)(MITNET_REACHABILITY_TATUS))callBack;


NS_ASSUME_NONNULL_END
@end
