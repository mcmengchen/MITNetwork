//
//  MITNetworkLogger.m
//  Pods
//
//  Created by MENGCHEN on 2017/3/7.
//
//

#import "MITNetworkLogger.h"
#import "AFURLSessionManager.h"
#import <objc/runtime.h>




static NSURLRequest * AFNetworkRequestFromNotification(NSNotification *notification) {
    NSURLRequest *request = nil;
    if ([[notification object] respondsToSelector:@selector(originalRequest)]) {
        request = [[notification object] originalRequest];
    } else if ([[notification object] respondsToSelector:@selector(request)]) {
        request = [[notification object] request];
    }
    return request;
}

static NSError * AFNetworkErrorFromNotification(NSNotification *notification) {
    NSError *error = nil;
    if ([[notification object] isKindOfClass:[NSURLSessionTask class]]) {
        error = [(NSURLSessionTask *)[notification object] error];
        if (!error) {
            error = notification.userInfo[AFNetworkingTaskDidCompleteErrorKey];
        }
    }
    
    return error;
}


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
    _enableDebug = enableDebug;
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
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}



#pragma mark ------------------ Notify ------------------

static void * AFNetworkRequestStartDate = &AFNetworkRequestStartDate;

- (void)networkRequestDidStart:(NSNotification *)notification {
    NSURLRequest *request = AFNetworkRequestFromNotification(notification);
    if (!request) {
        return;
    }
    objc_setAssociatedObject(notification.object, AFNetworkRequestStartDate, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *body = nil;
    if ([request HTTPBody]) {
        body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    }
    if (_enableDebug) {
        MITLog(@"\n ===================== HTTP Method ===================== \n %@ \n ===================== HTTP URL ===================== \n '%@': \n ===================== HTTP HeaderFields ===================== \n %@ \n ===================== HTTPBody ===================== \n %@ \n ===================== Logger End ===================== \n", [request HTTPMethod], [[request URL] absoluteString], [request allHTTPHeaderFields], body);
    }
}

- (void)networkRequestDidFinish:(NSNotification *)notification {
    NSURLRequest * request = AFNetworkRequestFromNotification(notification);
    NSURLResponse *response = [notification.object response];
    NSError *error = AFNetworkErrorFromNotification(notification);
    
    if (!request && !response) {
        return;
    }
    
    NSUInteger responseStatusCode = 0;
    NSDictionary *responseHeaderFields = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        responseStatusCode = (NSUInteger)[(NSHTTPURLResponse *)response statusCode];
        responseHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
    }
    
    id responseObject = notification.userInfo[AFNetworkingTaskDidCompleteSerializedResponseKey];
    if (responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            responseObject = [[NSDictionary alloc] initWithDictionary:responseObject];
        }
        else if ([responseObject isKindOfClass:[NSData class]]) {
            NSStringEncoding stringEncoding = NSUTF8StringEncoding;
            responseObject = [[NSString alloc] initWithData:responseObject encoding:stringEncoding];
        }
    }
    
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(notification.object, AFNetworkRequestStartDate)];
    if (_enableDebug) {
        if (error) {
            MITLog(@"[Error] %@ '%@' (%ld) [%.04f s]: %@", [request HTTPMethod], [[response URL] absoluteString], (long)responseStatusCode, elapsedTime, error);
            
        }else{
            MITLog(@"%ld '%@' [%.04f s]: %@ %@", (long)responseStatusCode, [[response URL] absoluteString], elapsedTime, responseHeaderFields, responseObject);
        }
    }
}



@end
