//
//  MITNetworkEngine.m
//  Pods
//
//  Created by MENGCHEN on 2017/3/7.
//
//

#import "MITNetworkEngine.h"
#import "MITNetworkRequest.h"
#import <pthread/pthread.h>
#import "MITNetworkCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "MITNetworkLogger.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)
#define MIT_SAFE_BLOCK(BlockName, ...) \
if(BlockName){\
BlockName(__VA_ARGS__);\
}
typedef void (^MITConstructingFormDataBlock)(id<AFMultipartFormData> formData);
typedef void (^MITNetStatusChangeCallBack)(MITNET_REACHABILITY_TATUS status);

@interface MITNetworkEngine()
{
    pthread_mutex_t _lock;
}
/** 请求字典 */
@property(nonatomic, strong)NSMutableDictionary<NSString*, __kindof MITNetworkRequest*> * requestDict;
/** 网络管理 */
@property(nonatomic, strong)AFHTTPSessionManager * manager;
/** json 回包序列化 */
@property(nonatomic, strong)AFJSONResponseSerializer * jsonResponseSerializer;
/** xml 回包序列化 */
@property(nonatomic, strong)AFXMLParserResponseSerializer * xmlResponseSerialzier;

/** 当前的网络状态  */
@property(nonatomic, assign)AFNetworkReachabilityStatus stataus;
/** 回调 */
@property(nonatomic, copy)MITNetStatusChangeCallBack callBack;

@end

@implementation MITNetworkEngine
#pragma mark action Load
+(void)load{
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
}

#pragma mark action 创建单例
+ (MITNetworkEngine *)defaultEngine{
    static MITNetworkEngine * engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[self alloc]init];
    });
    return engine;
}

#pragma mark action json 回包序列化
- (AFJSONResponseSerializer *)jsonResponseSerializer {
    if (!_jsonResponseSerializer) {
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        _jsonResponseSerializer.removesKeysWithNullValues = YES;
        
    }
    return _jsonResponseSerializer;
}

#pragma mark action xml 回包序列化
- (AFXMLParserResponseSerializer *)xmlParserResponseSerialzier {
    if (!_xmlResponseSerialzier) {
        _xmlResponseSerialzier = [AFXMLParserResponseSerializer serializer];
    }
    return _xmlResponseSerialzier;
}

#pragma mark action 获取当前网络类型
- (NSInteger)networkReachability {
    return [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
}

#pragma mark action init
- (instancetype)init{
    if (self = [super init]) {
        _requestDict = [NSMutableDictionary dictionaryWithCapacity:0];
        _manager = [AFHTTPSessionManager manager];
        _manager.operationQueue.maxConcurrentOperationCount = [MITNetworkConfig defaultConfig].maxOperationCount;
        pthread_mutex_init(&_lock,NULL);
        //获取当前的网络
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            _stataus = status;
            //如果有回调
            if ([MITNetworkEngine defaultEngine].callBack) {
                [MITNetworkEngine defaultEngine].callBack(status);
            }
        }];
        
    }
    return self;
}

#pragma mark action 获取当前网络状态
+ (MITNET_REACHABILITY_TATUS)getCurrentNetStatus{
    [MITNetworkEngine defaultEngine].stataus = [AFNetworkReachabilityManager manager].networkReachabilityStatus;
    return [MITNetworkEngine defaultEngine].stataus;
}

+ (void)setNetStatusChangeCallBack:(void (^)(MITNET_REACHABILITY_TATUS))callBack{
    [MITNetworkEngine defaultEngine].callBack = callBack;
}

#pragma mark action 发送请求
+ (MITNetworkRequest *)sendRequest:(MITRequestBlock)requestBlock onSuccess:(MITSuccessBlock)successBlock onFailure:(MITFailureBlock)failureBlock{
    return [MITNetworkEngine sendRequest:requestBlock onProgress:nil onSuccess:successBlock onFailure:failureBlock];
}

#pragma mark action 发送请求
+ (MITNetworkRequest *)sendRequest:(MITRequestBlock)requestBlock onProgress:(MITProgressBlock)progressBlock onSuccess:(MITSuccessBlock)successBlock onFailure:(MITSuccessBlock)failureBlock{
    MITNetworkRequest * request = [MITNetworkRequest new];
    if (request) {
        requestBlock(request);
    }
    [[MITNetworkEngine defaultEngine] mit_consistRequest:request onProgress:progressBlock onSuccess:successBlock onFailure:failureBlock];
    return request;
}

#pragma mark action 重组请求
- (MITNetworkRequest *)mit_consistRequest:(MITNetworkRequest *)request onProgress:(MITProgressBlock)progressBlock onSuccess:(MITSuccessBlock)successBlock onFailure:(MITSuccessBlock)failureBlock{
    //成功回调
    if (successBlock) {
        request.successBlock = successBlock;
    }
    //失败回调
    if (failureBlock) {
        request.failureBlock = failureBlock;
    }
    //过程回调
    if (progressBlock) {
        request.progressBlock = progressBlock;
    }
    switch (request.type) {
        case MITNET_TYPE_UPLOAD:
        {
            [self mit_startUploadTask:request];
        }
            break;
        case MITNET_TYPE_DOWNLOAD:
        {
            [self mit_startDownloadTask:request];
        }
            break;
        default:
        {
            [self mit_startDefaultTask:request];
        }
            break;
    }
    return request;
}


#pragma mark ------------------ Request Method ------------------
#pragma mark action 开始默认请求
- (void)mit_startDefaultTask:(MITNetworkRequest *)requestTask{
    NSMutableURLRequest *request =  [self mit_constructRequestConfigByRequest:requestTask bodyWithBlock:nil];
    //如果是只读缓存的类型
    if (requestTask.cachePolicy == MITNET_REQUEST_CACHE_ONLY) {
        MITLog(@"缓存只读");
        id obj = [MITNetworkCache mit_CacheWithURL:requestTask.url params:requestTask.parameters];
        if (obj &&![obj isKindOfClass:[NSNull class]]) {
            if (requestTask.successBlock) {
                requestTask.successBlock(obj);
            }
        }
        return;
    }

    __block NSURLSessionDataTask *dataTask = nil;
    __weak __typeof(self)weakSelf = self;
    dataTask = [self.manager dataTaskWithRequest:request
                                      completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                          __strong __typeof(weakSelf)strongSelf = weakSelf;
                                          [strongSelf handleResponseResult:dataTask responseObject:responseObject error:error];
                                      }];
    requestTask.requestTask = dataTask;
    [dataTask resume];
    [self mit_addRequestTask:requestTask];
}

#pragma mark action 开始上传
- (void)mit_startUploadTask:(MITNetworkRequest *)uploadTask{
    MITConstructingFormDataBlock formDataBlock =  ^( id <AFMultipartFormData> formData) {
        [uploadTask.uploadFormDatas enumerateObjectsUsingBlock:^(MITNetworkUploadFormData *obj, NSUInteger idx, BOOL *stop) {
            if (obj.fileData) {
                if (obj.fileName && obj.mimeType) {
                    [formData appendPartWithFileData:obj.fileData name:obj.name fileName:obj.fileName mimeType:obj.mimeType];
                } else {
                    [formData appendPartWithFormData:obj.fileData name:obj.name];
                }
            } else if (obj.fileURL) {
                NSError *fileError = nil;
                if (obj.fileName && obj.mimeType) {
                    [formData appendPartWithFileURL:obj.fileURL name:obj.name fileName:obj.fileName mimeType:obj.mimeType error:&fileError];
                } else {
                    [formData appendPartWithFileURL:obj.fileURL name:obj.name error:&fileError];
                }
                if (fileError) {
                    *stop = YES;
                }
            }
        }];
    };
    NSMutableURLRequest  *request =[self mit_constructRequestConfigByRequest:uploadTask bodyWithBlock:formDataBlock];
    __block  NSURLSessionUploadTask *uploadDataTask = nil;
    uploadDataTask = [self.manager uploadTaskWithStreamedRequest:request  progress:^(NSProgress *progress){
        if (uploadTask.progressBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                uploadTask.progressBlock(progress);
            });
        }
    }completionHandler:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject, NSError * _Nonnull error){
        [self handleResponseResult:uploadDataTask responseObject:responseObject error:error];
    }];
    uploadTask.requestTask = uploadDataTask;
    [uploadDataTask resume];
    [self mit_addRequestTask:uploadTask];
}


#pragma mark action 开始下载
-(void)mit_startDownloadTask:(MITNetworkRequest *)downloadRequest{
    //创建请求
    NSMutableURLRequest *urlRequest = [self mit_constructRequestConfigByRequest:downloadRequest bodyWithBlock:nil];
    //获取缓存路径
    NSString *downloadTempCachePath = [self incompleteDownloadTempPathForDownloadPath:downloadRequest.downloadSavePath];
    BOOL resumeDataFileExists = [[NSFileManager defaultManager] fileExistsAtPath:downloadTempCachePath];
    NSData * data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:downloadTempCachePath]];
    BOOL resumeDataIsValid = [self validateResumeData:data];
    BOOL canBeResumed = resumeDataFileExists && resumeDataIsValid;
    BOOL resumeSucceeded = NO;
    __block NSURLSessionDownloadTask *downloadTask = nil;
    if (canBeResumed) {
        @try {
            downloadTask = [self.manager downloadTaskWithResumeData:data progress:downloadRequest.progressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                downloadRequest.resumDownloadPath = targetPath;
                NSURL * url = [NSURL fileURLWithPath:downloadRequest.downloadSavePath isDirectory:NO];
                MITLog(@"url = %@",url);
                return url;
            } completionHandler:
                            ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                [self handleResponseResult:downloadTask responseObject:filePath error:error];
                            }];
            resumeSucceeded = YES;
        } @catch (NSException *exception) {
            resumeSucceeded = NO;
        }
    }
    if (!resumeSucceeded) {
        downloadTask = [self.manager downloadTaskWithRequest:urlRequest progress:downloadRequest.progressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            downloadRequest.resumDownloadPath = targetPath;
            NSURL * url = [NSURL fileURLWithPath:downloadRequest.downloadSavePath isDirectory:NO];
            MITLog(@"url = %@",url);
            return url;
        } completionHandler:
                        ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                            [self handleResponseResult:downloadTask responseObject:filePath error:error];
                        }];
    }
    downloadRequest.requestTask = downloadTask;
    [downloadTask resume];
    [self mit_addRequestTask:downloadRequest];
}

#pragma mark action 处理回包
- (void)handleResponseResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    Lock();
    MITNetworkRequest *request = _requestDict[@(task.taskIdentifier)];
    Unlock();
    [self mit_responseSerializerByRequest:request];
    NSError * __autoreleasing serializationError = nil;
    NSError * __autoreleasing validationError = nil;
    NSError *requestError = nil;
    request.responseObject = responseObject;
    request.responseStatusCode = [(NSHTTPURLResponse *)task.response statusCode];
    BOOL succeed = NO;
    if ([request.responseObject isKindOfClass:[NSData class]]) {
        request.responseData = responseObject;
        switch (request.responseSerializerType) {
            case MITNET_RESPONSE_SERIALIZERTYPE_HTTP:
                break;
            case MITNET_RESPONSE_SERIALIZERTYPE_JSON:
                request.responseObject = [self.manager.responseSerializer responseObjectForResponse:task.response data:request.responseData error:&serializationError];
                request.responseJSONObject = request.responseObject;
                break;
            case MITNET_RESPONSE_SERIALIZERTYPE_XML:
                request.responseObject = [self.manager.responseSerializer responseObjectForResponse:task.response data:request.responseData error:&serializationError];
                break;
        }
    }
    if (error) {
        succeed = NO;
        requestError = error;
    } else if (serializationError) {
        succeed = NO;
        requestError = serializationError;
    } else {
        succeed = YES;
    }
    //完成回调
    MIT_SAFE_BLOCK(request.finishBlock,request.responseObject,requestError);
    if (succeed) {
        [self requestDidSucceedWithRequest:request];
    } else {
        [self requestDidFailWithRequest:request error:error];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [request clearRequestBlock];
    });
}

#pragma mark action 请求成功回调
- (void)requestDidSucceedWithRequest:(MITNetworkRequest *)request {
    //刷新缓存
    if (request.cachePolicy == MITNET_REQUEST_CACHE_REFRESH) {
        [MITNetworkCache mit_setCache:request.responseObject URL:request.url params:request.parameters];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.successBlock) {
            request.successBlock(request.responseObject);
        }
    });
    [self removeRequest:request];
}

#pragma mark action 请求失败回调
- (void)requestDidFailWithRequest:(MITNetworkRequest *)request error:(NSError *)error {
    if (request.resumDownloadPath&&(request.type == MITNET_TYPE_DOWNLOAD)&&request.allowResume) {
        NSData *incompleteDownloadData = error.userInfo[NSURLSessionDownloadTaskResumeData];
        if (incompleteDownloadData) {
            [incompleteDownloadData writeToURL:[self incompleteDownloadTempPathForDownloadPath:request.resumDownloadPath] atomically:YES];
        }
        NSData * data= [NSData dataWithContentsOfURL:[NSURL URLWithString:request.resumDownloadPath]];
        MITLog(@"data = %@",data);
    }
    if ([request.responseObject isKindOfClass:[NSURL class]]) {
        NSURL *url = request.responseObject;
        if (url.isFileURL && [[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
            request.responseData = [NSData dataWithContentsOfURL:url];
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        }
        request.responseObject = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.failureBlock) {
            request.failureBlock(error);
        }
    });
    [self removeRequest:request];
}

#pragma mark action 回包序列化
- (void)mit_responseSerializerByRequest:(__kindof MITNetworkRequest *)request {
    switch (request.responseSerializerType) {
        case MITNET_RESPONSE_SERIALIZERTYPE_HTTP:
            self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        case MITNET_RESPONSE_SERIALIZERTYPE_JSON:
            if (![self.manager.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]]) {
                self.manager.responseSerializer = self.jsonResponseSerializer;
            }
            break;
        case MITNET_RESPONSE_SERIALIZERTYPE_XML:
            if (![self.manager.responseSerializer isKindOfClass:[AFXMLParserResponseSerializer class]]) {
                self.manager.responseSerializer = self.xmlResponseSerialzier;
            }
            break;
        case MITNET_RESPONSE_SERIALIZERTYPE_PROPERTYLIST:
            if (![self.manager.responseSerializer isKindOfClass:[AFPropertyListResponseSerializer class]]) {
                self.manager.responseSerializer = [AFPropertyListResponseSerializer serializer];
            }
            break;
        default:
            break;
    }
    self.manager.responseSerializer.acceptableStatusCodes = request.acceptableStatusCodes;
    self.manager.responseSerializer.acceptableContentTypes = request.acceptableContentTypes;
}


#pragma mark action 将任务添加到字典中
- (void)mit_addRequestTask:(__kindof MITNetworkRequest*)request {
    if (request == nil)    return;
    Lock();
    _requestDict[@(request.requestTask.taskIdentifier)] = request;
    Unlock();
}

#pragma mark action 构建请求
- (NSMutableURLRequest *)mit_constructRequestConfigByRequest:(__kindof MITNetworkRequest *)requestTask bodyWithBlock:(void(^)(id<AFMultipartFormData> _Nonnull formData))formDataBlock{
    if (requestTask.url.length == 0) {
        if (requestTask.hostUrl.length == 0) {
            requestTask.hostUrl =  [MITNetworkConfig defaultConfig].hostUrl;
        }
        if (requestTask.api.length > 0) {
            NSURL *baseURL = [NSURL URLWithString:requestTask.hostUrl];
            // ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected.
            if ([[baseURL path] length] > 0 && ![[baseURL absoluteString] hasSuffix:@"/"]) {
                baseURL = [baseURL URLByAppendingPathComponent:@""];
            }
            requestTask.url = [[NSURL URLWithString:requestTask.api relativeToURL:baseURL] absoluteString];
        } else {
            requestTask.url = requestTask.hostUrl;
        }
    }
    NSAssert(requestTask.url.length > 0, @"The request url can't be null.");
    //添加默认参数
    if (requestTask.addDefaultParameters) {
        NSDictionary *defaultParameter  = [MITNetworkConfig defaultConfig].defaultParameters;
        if (defaultParameter.count>0) {
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters addEntriesFromDictionary:defaultParameter];
            if (requestTask.parameters.count) {
                [parameters addEntriesFromDictionary:requestTask.parameters];
            }
            requestTask.parameters = parameters;
        }
    }
    //添加默认请求头
    if (requestTask.addDefaultHeaders) {
        NSDictionary *defaultHeaders  = [MITNetworkConfig defaultConfig].defaultHeaders;
        if (defaultHeaders.count>0) {
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters addEntriesFromDictionary:defaultHeaders];
            if (requestTask.headers.count) {
                [parameters addEntriesFromDictionary:requestTask.headers];
            }
            requestTask.headers = parameters;
        }
    }
    AFHTTPRequestSerializer *requestSerializer = self.manager;
    switch (requestTask.requestSerializerType) {
        case MITNET_REQUEST_SERIALIZERTYPE_HTTP:
            requestSerializer= [AFHTTPRequestSerializer serializer];
            break;
        case MITNET_REQUEST_SERIALIZERTYPE_JSON:
            if (![requestSerializer isKindOfClass:[AFJSONRequestSerializer class]]) {
                requestSerializer = [AFJSONRequestSerializer serializer];
            }
            break;
        case MITNET_REQUEST_SERIALIZERTYPE_PROPERTYLIST:
            if (![requestSerializer isKindOfClass:[AFPropertyListRequestSerializer class]]) {
                requestSerializer = [AFPropertyListRequestSerializer serializer];
            }
            break;
        default:
            break;
    }
    NSString *methodString = [self mit_httpMethodStringByRequest:requestTask];
    NSError *serializationError = nil;
    NSMutableURLRequest *request = nil;
    if (formDataBlock) {
        request = [requestSerializer multipartFormRequestWithMethod:methodString URLString:requestTask.url parameters:requestTask.parameters constructingBodyWithBlock:formDataBlock error:&serializationError];
    }else{
        request = [requestSerializer requestWithMethod:methodString URLString:requestTask.url parameters:requestTask.parameters error:&serializationError];
    }
    if (serializationError) {
        if (requestTask.failureBlock) {
            requestTask.failureBlock(serializationError);
        }
        return  request;
    }
    if (requestTask.headers.count > 0) {
        [requestTask.headers enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            [request setValue:value forHTTPHeaderField:field];
        }];
    }
    if (requestTask.type == MITNET_TYPE_DOWNLOAD) {
        [self mit_completeDownloadSavePathByRequest:requestTask];
    }
    request.timeoutInterval = requestTask.timeout;
    request.allowsCellularAccess = requestTask.allowsCellularAccess;
    return  request;
}


#pragma mark action 获取请求方式
- (NSString *)mit_httpMethodStringByRequest:(__kindof MITNetworkRequest  *)request
{
    NSString *method = nil;
    switch (request.method)
    {
        case MITNET_REQUEST_METHOD_GET:
            method = @"GET";
            break;
        case MITNET_REQUEST_METHOD_POST:
            method = @"POST";
            break;
        case MITNET_REQUEST_METHOD_PUT:
            method = @"PUT";
            break;
        case MITNET_REQUEST_METHOD_DELETE:
            method = @"DELETE";
            break;
        case MITNET_REQUEST_METHOD_OPTIONS:
            method = @"OPTIONS";
            break;
        case MITNET_REQUEST_METHOD_HEAD:
            method = @"HEAD";
            break;
        default:
            method = @"GET";
            break;
    }
    return method;
}

#pragma mark action 获取下载路径
- (void)mit_completeDownloadSavePathByRequest:(MITNetworkRequest*)downloadRequest{
    NSString *fileSavePathTemp = downloadRequest.downloadSavePath;
    if (!fileSavePathTemp) {
        fileSavePathTemp = [MITNetworkConfig defaultConfig].defaultDownloadFolder;
    }
    BOOL isDirectory;
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileSavePathTemp isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    if (isDirectory) {
        NSString *fileName = [downloadRequest.url lastPathComponent];
        fileSavePathTemp = [NSString pathWithComponents:@[fileSavePathTemp, fileName]];;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileSavePathTemp]) {
        [[NSFileManager defaultManager] removeItemAtPath:fileSavePathTemp error:nil];
    }
    downloadRequest.downloadSavePath = fileSavePathTemp;
}



#pragma mark action 校验之前下载数据
- (BOOL)validateResumeData:(NSData *)data {
    // From http://stackoverflow.com/a/22137510/3562486
    if (!data || [data length] < 1) return NO;
    
    NSError *error;
    NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
    if (!resumeDictionary || error) return NO;
    
    // Before iOS 9 & Mac OS X 10.11
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED < 90000)\
|| (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED < 101100)
    NSString *localFilePath = [resumeDictionary objectForKey:@"NSURLSessionResumeInfoLocalPath"];
    if ([localFilePath length] < 1) return NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:localFilePath];
#endif
    // After iOS 9 we can not actually detects if the cache file exists. This plist file has a somehow
    // complicated structue. Besides, the plist structure is different between iOS 9 and iOS 10.
    // We can only assume that the plist being successfully parsed means the resume data is valid.
    return YES;
}


#pragma mark action 获取未完成的路径
- (NSString *)incompleteDownloadTempPathForDownloadPath:(NSString *)downloadPath {
    NSString *tempPath = nil;
    NSString *md5URLString = [self md5String:downloadPath];
    tempPath = [[self downloadTempCacheFolder] stringByAppendingPathComponent:md5URLString];
    return tempPath;
}

#pragma mark action 获取临时缓存文件夹
- (NSString *)downloadTempCacheFolder {
    NSFileManager *fileManager = [NSFileManager new];
    static NSString *tempFolder;
    if (!tempFolder) {
        NSString *tempDir = NSTemporaryDirectory();
        tempFolder = [tempDir stringByAppendingPathComponent:@"RBDownloadTemp"];
    }
    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:tempFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        tempFolder = nil;
    }
    return tempFolder;
}

#pragma mark action MD5
- (NSString *)md5String:(NSString *)string {
    if (string.length <= 0) {
        return nil;
    }
    const char *value = [string UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}


#pragma mark action 取消网络请求
+ (void)cancelRequest:(MITNetworkRequest *)request Block:(void (^)(BOOL,MITNET_REQUEST_STEP))cancelBlock{
    [[MITNetworkEngine defaultEngine] cancelRequest:request Block:cancelBlock];
}

- (void)cancelRequest:(MITNetworkRequest *)request Block:(void(^)(BOOL,MITNET_REQUEST_STEP))cancelBlock{
    if (!request) {
        return;
    }
    MITNetworkRequest * resultRequest = [_requestDict objectForKey:@(request.requestTask.taskIdentifier)];
    if (resultRequest&&resultRequest.requestTask) {
        [resultRequest.requestTask cancel];
        MITLog(@"statet = %ld",resultRequest.requestTask.state);
        switch (resultRequest.requestTask.state) {
            case NSURLSessionTaskStateRunning:
            {
                if (cancelBlock) {
                    cancelBlock(false,MITNET_REQUEST_STEP_RUNNING);
                }
            }
                break;
            case NSURLSessionTaskStateSuspended:
            {
                if (cancelBlock) {
                    cancelBlock(false,MITNET_REQUEST_STEP_SUSPENDED);
                }
            }
                break;
            case NSURLSessionTaskStateCanceling:
            {
                if (cancelBlock) {
                    cancelBlock(true,MITNET_REQUEST_STEP_CANCELLING);
                }
            }
                break;
            case NSURLSessionTaskStateCompleted:
            {
                if (cancelBlock) {
                    cancelBlock(true,MITNET_REQUEST_STEP_COMPLETED);
                }
            }
                break;
            default:
                break;
        }
        [self removeRequest:request];
    } else {
        if (cancelBlock) {
            cancelBlock(false,MITNET_REQUEST_STEP_NONE);
        }
        return;
    }
}

#pragma mark action 暂停
+ (void)suspend:(MITNetworkRequest *)request{
    [request.requestTask suspend];
}

#pragma mark action 继续
+ (void)resume:(MITNetworkRequest *)request{
    [request.requestTask resume];
}

#pragma mark action 移除请求
- (void)removeRequest:(MITNetworkRequest *)request{
    Lock();
    [_requestDict removeObjectForKey:@(request.requestTask.taskIdentifier)];
    Unlock();
}
#pragma mark action 取消所有请求
+(void)cancelAllRequest{
    [[MITNetworkEngine defaultEngine] cancelAllRequest];
}
- (void)cancelAllRequest{
    Lock();
    __block MITNetworkRequest * request = nil;
    [[MITNetworkEngine defaultEngine].requestDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, __kindof MITNetworkRequest * _Nonnull obj, BOOL * _Nonnull stop) {
        request = (MITNetworkRequest * )obj;
        [MITNetworkEngine cancelRequest:request Block:nil];
    }];
    Unlock();
}


#pragma mark action 清空所有缓存
+ (void)clearAllCache{
    [[MITNetworkEngine defaultEngine] clearAllCache];
}

- (void)clearAllCache{
    [MITNetworkCache removeAllCache];
}


#pragma mark action dealloc
-(void)dealloc{
    pthread_mutex_destroy(&_lock);
}

@end
