//
//  MITNetworkLogger.h
//  Pods
//
//  Created by MENGCHEN on 2017/3/7.
//
//

#import <Foundation/Foundation.h>
#ifdef DEBUG
#define MITLog(...) printf("[%s] %s [第%d行]: %s\n", __TIME__ ,__PRETTY_FUNCTION__ ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define MITLog(...)
#endif
@interface MITNetworkLogger : NSObject

/** 是否允许 debug */
@property(nonatomic, assign)BOOL enableDebug;

+ (instancetype)sharedLogger;

@end
