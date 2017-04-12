//
//  MITNetworkConfig.m
//  Pods
//
//  Created by MENGCHEN on 2017/3/7.
//
//

#import "MITNetworkConfig.h"
#import "MITNetworkLogger.h"
#import "MITNetworkCookie.h"
#define MIT_TIMEOUT 20
#define MIT_OPRETION_COUT 5

@implementation MITNetworkConfig
+(MITNetworkConfig *)defaultConfig{
    static MITNetworkConfig * config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[self alloc]init];
    });
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _defaultMethod = MITNET_REQUEST_METHOD_GET;
        _defaultAcceptableStatusCodes =  [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)];
        _defaultAcceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
        _requestSerializer = MITNET_REQUEST_SERIALIZERTYPE_HTTP;
        _responseSerializer = MITNET_RESPONSE_SERIALIZERTYPE_HTTP;
        _defaultTimeoutInterval = MIT_TIMEOUT;
        _defaultAcceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 500)];
        _maxOperationCount = MIT_OPRETION_COUT;
        _resumeType = MITNET_RESUME_DATA_TYPE_ALLOW;
        NSString * docmentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString * tempDownloadFolder = [docmentPath stringByAppendingPathComponent:@"MITNetworkDownload"];
        NSError * error = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:tempDownloadFolder]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:tempDownloadFolder withIntermediateDirectories:YES attributes:nil error:&error];
        }
        _defaultDownloadFolder = tempDownloadFolder;
        _cachePolicy = MITNET_REQUEST_CACHE_REFRESH;
        _cookieEnable = false;
        self.enableDebug = false;
        
    }
    return self;
}

#pragma mark action 设置 debug 环境
- (void)setEnableDebug:(BOOL)enableDebug{
    _enableDebug = enableDebug;
    [MITNetworkLogger sharedLogger].enableDebug = enableDebug;
}




@end
