//
//  MITNetworkConfig.h
//  Pods
//
//  Created by MENGCHEN on 2017/3/7.
//
//

#import <Foundation/Foundation.h>
@class MITNetworkRequest;
@class MITNetworkCookieModel;

NS_ASSUME_NONNULL_BEGIN

//请求类型
typedef NS_ENUM(NSUInteger, MITNET_REQUEST_METHOD) {
    MITNET_REQUEST_METHOD_GET,
    MITNET_REQUEST_METHOD_POST,
    MITNET_REQUEST_METHOD_PUT,
    MITNET_REQUEST_METHOD_DELETE,
    MITNET_REQUEST_METHOD_HEAD,
    MITNET_REQUEST_METHOD_OPTIONS
};

//缓存配置
typedef NS_ENUM(NSUInteger, MITNET_REQUEST_CACHE) {
    //拉取之后更新缓存
    MITNET_REQUEST_CACHE_REFRESH,
    //只从缓存中读，没有返回 nil
    MITNET_REQUEST_CACHE_ONLY,
};

//请求序列化类型
typedef NS_ENUM(NSUInteger, MITNET_REQUEST_SERIALIZERTYPE) {
    MITNET_REQUEST_SERIALIZERTYPE_HTTP = 0,
    MITNET_REQUEST_SERIALIZERTYPE_JSON = 1,
    MITNET_REQUEST_SERIALIZERTYPE_PROPERTYLIST = 2,
};
//回包序列化类型
typedef NS_ENUM(NSUInteger, MITNET_RESPONSE_SERIALIZERTYPE) {
    MITNET_RESPONSE_SERIALIZERTYPE_HTTP,
    MITNET_RESPONSE_SERIALIZERTYPE_XML,
    MITNET_RESPONSE_SERIALIZERTYPE_JSON,
    MITNET_RESPONSE_SERIALIZERTYPE_PROPERTYLIST
};
//优先级
typedef NS_ENUM(NSUInteger, MITNET_PRIORITY) {
    MITNET_PRIORITY_LOW = -4,
    MITNET_PRIORITY_DEFAULT = 0,
    MITNET_PRIORITY_HIGH = 4,
};

//网络请求类型
typedef NS_ENUM(NSUInteger, MITNET_TYPE) {
    //上传
    MITNET_TYPE_UPLOAD,
    //下载
    MITNET_TYPE_DOWNLOAD,
    //正常请求
    MITNET_TYPE_REQUEST,
};

//网络请求阶段
typedef NS_ENUM(NSUInteger, MITNET_REQUEST_STEP) {
    MITNET_REQUEST_STEP_RUNNING = 0,
    MITNET_REQUEST_STEP_SUSPENDED = 1,
    MITNET_REQUEST_STEP_CANCELLING = 2,
    MITNET_REQUEST_STEP_COMPLETED = 3,
    MITNET_REQUEST_STEP_NONE = 4,
};


//断点续传的类型
typedef NS_ENUM(NSUInteger, MITNET_RESUME_DATA_TYPE) {
    MITNET_RESUME_DATA_TYPE_ALLOW,
    MITNET_RESUME_DATA_TYPE_BAN,
};

//当前网络状态
typedef NS_ENUM(NSUInteger, MITNET_REACHABILITY_TATUS) {
    MITNET_REACHABILITY_TATUS_UNKNOWN          = -1,
    MITNET_REACHABILITY_TATUS_NOT     = 0,
    MITNET_REACHABILITY_TATUS_ViaWWAN = 1,
    MITNET_REACHABILITY_TATUS_ViaWiFi = 2,
};

//下载缓存枚举
typedef NS_OPTIONS(NSUInteger, MITNET_DOWNLOADCACHE_TYPE) {
    MITNET_DOWNLOADCACHE_TYPE_MEMORY = 1 << 0,
    MITNET_DOWNLOADCACHE_TYPE_FILE = 1 << 1,
};


typedef void (^MITRequestBlock)(MITNetworkRequest *_Nullable request);
typedef void (^MITCancelBlock)(MITNetworkRequest * _Nullable request);
typedef void (^MITProgressBlock)(NSProgress *_Nullable progress);
typedef void (^MITSuccessBlock)(id _Nullable responseObject);
typedef void (^MITFailureBlock)(NSError * _Nullable error);
typedef void (^MITFinishedBlock)(id _Nullable responseObject, NSError * _Nullable error);

@interface MITNetworkConfig : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;


/** 默认配置 */
+ (MITNetworkConfig *)defaultConfig;

/** url 地址 */
@property(nonatomic, strong)NSString * hostUrl;
/**
 *   默认的请求头
 */
@property (nonatomic, copy,nullable) NSDictionary<NSString *,NSString *>* defaultHeaders;
/**
 *  默认的请求参数
 */
@property (nonatomic, copy,nullable) NSDictionary<NSString *,NSString *>* defaultParameters;

/** 默认请求方法 */
@property(nonatomic, assign)MITNET_REQUEST_METHOD defaultMethod;

/** 默认请求序列化方式 */
@property(nonatomic, assign)MITNET_REQUEST_SERIALIZERTYPE requestSerializer;

/** 默认相应序列化方式 */
@property(nonatomic, assign)MITNET_RESPONSE_SERIALIZERTYPE responseSerializer;

/**  最大并发数 */
@property(nonatomic, assign)NSUInteger maxOperationCount;
/**
 https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html 默认是200-500
 */
@property (nonatomic, copy, nullable) NSIndexSet *defaultAcceptableStatusCodes;
/**
 *   默认：[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil]
 */
@property (nonatomic, copy,nullable) NSSet<NSString *> *defaultAcceptableContentTypes;
/**
 *  @brief 请求超时时间，默认20秒
 */
@property (nonatomic, assign,) NSTimeInterval defaultTimeoutInterval;

/**
 *  存储下载数据的文件夹 /Library/Caches/MITNetworkDownload
 */
@property (nonatomic,copy,nullable) NSString *defaultDownloadFolder;


/** 断点续传类型 */
@property(nonatomic, assign)MITNET_RESUME_DATA_TYPE resumeType;

/** 断点续传路径 */
@property(nonatomic, strong)NSString * resumePath;

/** 是否 debug 模式 */
@property(nonatomic, assign)BOOL enableDebug;

/** 缓存策略 */
@property(nonatomic, assign)MITNET_REQUEST_CACHE  cachePolicy;

/** 缓存时间限制 */
@property(nonatomic, assign)NSTimeInterval cacheAgeLimit;

/** 缓存消耗限制 */
@property(nonatomic, assign)NSUInteger cacheCostLimit;


/** 是否保存 cookie */
@property (nonatomic, assign) BOOL cookieEnable;


/* cookie 模型 */
@property (nonatomic, strong) MITNetworkCookieModel * cookieModel;







NS_ASSUME_NONNULL_END
@end
