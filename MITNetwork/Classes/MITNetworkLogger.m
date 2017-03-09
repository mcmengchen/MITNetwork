//
//  MITNetworkLogger.m
//  Pods
//
//  Created by MENGCHEN on 2017/3/7.
//
//

#import "MITNetworkLogger.h"
#import "AFURLSessionManager.h"

@implementation MITNetworkLogger

+ (instancetype)sharedLogger{
    static MITNetworkLogger * logger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[self alloc]init];
    });
    return logger;
}

- (void)setEnableDebug:(BOOL)enableDebug{
    if (enableDebug) {
        [self startLog];
    } else {
        [self stopLog];
    }
}



- (void)startLog{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidStart:) name:AFNetworkingTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidFinish:) name:AFNetworkingTaskDidCompleteNotification object:nil];
    
}

- (void)stopLog{
    
    
}

@end
