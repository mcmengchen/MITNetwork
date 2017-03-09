//
//  MITNetworkLogger.h
//  Pods
//
//  Created by MENGCHEN on 2017/3/7.
//
//

#import <Foundation/Foundation.h>

@interface MITNetworkLogger : NSObject

/** 是否允许 debug */
@property(nonatomic, assign)BOOL enableDebug;

+ (instancetype)sharedLogger;

@end
