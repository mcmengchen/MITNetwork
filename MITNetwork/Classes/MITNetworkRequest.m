//
//  MitNetworkRequest.m
//  Pods
//
//  Created by MENGCHEN on 2017/3/8.
//
//

#import "MITNetworkRequest.h"
#import "MITNetworkUploadFormData.h"
@implementation MITNetworkRequest


#pragma mark action 初始化
- (instancetype)init{
    if (self = [super init]) {
        MITNetworkConfig * config = [MITNetworkConfig defaultConfig];
        _hostUrl = config.hostUrl;
        _timeout = config.defaultTimeoutInterval;
        _method = config.defaultMethod;
        _type = MITNET_TYPE_REQUEST;
        _requestSerializerType = config.requestSerializer;
        _responseSerializerType = config.responseSerializer;
        _acceptableContentTypes = config.defaultAcceptableContentTypes;
        _acceptableStatusCodes = config.defaultAcceptableStatusCodes;
        _allowsCellularAccess = true;
        _addDefaultHeaders = true;
        _addDefaultParameters = true;
        _cachePolicy = config.cachePolicy;
        switch (config.resumeType) {
            case MITNET_RESUME_DATA_TYPE_ALLOW:
            {
                _allowResume = true;
            }
                break;
            case MITNET_RESUME_DATA_TYPE_BAN:
            {
                _allowResume = false;
                
            }
                break;
            default:
            {
                _allowResume = true;
            }
                break;
        }
    }
    return self;
}


#pragma mark create 创建上传数据数组
- (NSMutableArray<MITNetworkUploadFormData *> *)uploadFormDatas{
    if (!_uploadFormDatas) {
        NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
        _uploadFormDatas = arr;
    }
    return _uploadFormDatas;
}


- (void)addFormDataWithName:(NSString *)name fileURL:(NSURL *)fileURL{
    MITNetworkUploadFormData * formData = [MITNetworkUploadFormData formDataWithName:name fileURL:fileURL];
    [self.uploadFormDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name fileData:(NSData *)fileData{
    MITNetworkUploadFormData * formData = [MITNetworkUploadFormData formDataWithName:name fileData:fileData];
    [self.uploadFormDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData{
    MITNetworkUploadFormData * formData = [MITNetworkUploadFormData formDataWithName:name fileName:fileName mimeType:mimeType fileData:fileData];
}
- (void)addFormDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL{
    MITNetworkUploadFormData * formData = [MITNetworkUploadFormData formDataWithName:name fileName:fileName mimeType:mimeType fileURL:fileURL];
}
- (void)clearRequestBlock {
    _successBlock = nil;
    _failureBlock = nil;
    _progressBlock = nil;
}

-(void)dealloc{
    [self clearRequestBlock];
}

-(NSString *)description{
    NSString * str = @"";
    for (id obj in self) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%@",obj]];
    }
    return str;
}


@end
