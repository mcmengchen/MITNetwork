//
//  MitNetworkRequest.h
//  Pods
//
//  Created by MENGCHEN on 2017/3/8.
//
//

#import <Foundation/Foundation.h>
#import "MITNetworkConfig.h"
#import "MITNetworkUploadFormData.h"


@interface MITNetworkRequest : NSObject
/**
 请求任务
 */
@property (nonatomic, strong,nullable) NSURLSessionTask * requestTask;

/**
 请求的类型 默认 HTTP type,
 //上传
 MITNET_TYPE_UPLOAD,
 //下载
 MITNET_TYPE_DOWNLOAD,
 //正常请求
 MITNET_TYPE_REQUEST,
 */
@property (nonatomic, assign) MITNET_TYPE type;
/**
 *  服务器地址 eg https://www.baidu.com
 */
@property (nonatomic, copy,nullable) NSString * hostUrl;

/**
 *  服务器的接口 eg /foo/bar/
 */
@property (nonatomic, strong,nullable) NSString * api;

/**
 请求的完整地址 eg https://www.baidu.com/files/ 
 */
@property (nonatomic, strong,nullable) NSString *url;

/**
 *  请求方法
 */
@property (nonatomic, assign) MITNET_REQUEST_METHOD method;

/**
 *  Timeout 超时时间
 */
@property (nonatomic, assign) NSTimeInterval timeout;

/**
 是否允许使用蜂窝数据 默认允许
 */
@property (nonatomic, assign) BOOL allowsCellularAccess;

/**
 请求header
 */
@property (nonatomic, copy,nullable)NSDictionary<NSString *,NSString *>*headers;

/**
 是否使用MITNetworkConfig 中defaultHeaders  默认是YES
 */
@property (nonatomic, assign) BOOL addDefaultHeaders;

/**
 请求参数
 */
@property (nonatomic,strong,nullable)  NSDictionary *parameters;

/**
 是否使用MITNetworkConfig 中defaultParams 默认是YES
 */
@property (nonatomic, assign) BOOL addDefaultParameters;
/**
 Request 序列化类型
 */
@property (nonatomic, assign) MITNET_REQUEST_SERIALIZERTYPE  requestSerializerType;

/**
 Response 序列化类型
 */
@property (nonatomic, assign) MITNET_RESPONSE_SERIALIZERTYPE responseSerializerType;
/**
 下载的存储路径
 */
@property (nonatomic, copy,nullable) NSString * downloadSavePath;

/**
 断点下载的存储路径
 */
@property (nonatomic, copy,nullable) NSString * resumDownloadPath;

/** 是否可以断点下载 */
@property(nonatomic, assign)BOOL allowResume;
/**
 请求成功的回调
 */
@property (nonatomic, copy, nullable) MITSuccessBlock successBlock;

/**
 请求失败的回调
 */
@property (nonatomic, copy, nullable) MITFailureBlock failureBlock;

/**
 请求的进度回调
 */
@property (nonatomic, copy, nullable) MITProgressBlock progressBlock;

/**
 请求的数据回调
 */
@property(nonatomic,copy,nullable) MITFinishedBlock finishBlock;

/**
 *  请求的缓存策略
 */
@property (nonatomic, assign) MITNET_REQUEST_CACHE cachePolicy;


/**
 [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil]
 */
@property (nonatomic, copy,nullable) NSSet<NSString *> *acceptableContentTypes;

/**
 默认是200-500；
 */
@property (nonatomic, copy, nullable) NSIndexSet *acceptableStatusCodes;

/**
 返回的状态码
 */
@property (nonatomic, readwrite, assign) NSInteger responseStatusCode;

/**
 响应对象
 */
@property (nonatomic, strong, readwrite, nullable) id responseObject;

/**
 响应数据
 */
@property (nonatomic, strong, readwrite, nullable) NSData *responseData;

/**
 相应对象
 */
@property (nonatomic, strong, readwrite, nullable) id responseJSONObject;

@property(nonatomic,strong,nullable) NSMutableArray<MITNetworkUploadFormData *>*uploadFormDatas;
- (void)addFormDataWithName:(nonnull NSString *)name fileData:(nonnull NSData *)fileData;
- (void)addFormDataWithName:(nonnull NSString *)name fileName:(nullable NSString *)fileName mimeType:(nullable NSString *)mimeType fileData:(nonnull NSData *)fileData;
- (void)addFormDataWithName:(nonnull NSString *)name fileURL:(nonnull NSURL *)fileURL;
- (void)addFormDataWithName:(nonnull NSString *)name fileName:(nullable NSString *)fileName mimeType:(nullable NSString *)mimeType fileURL:(nonnull NSURL *)fileURL;
- (void)clearRequestBlock;

@end
