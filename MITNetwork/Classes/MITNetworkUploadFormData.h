//
//  MITNetworkFormData.h
//  Pods
//
//  Created by MENGCHEN on 2017/3/7.
//
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface MITNetworkUploadFormData : NSObject
@property (nonatomic, copy,nonnull) NSString *name;
@property (nonatomic, copy, nullable) NSString *fileName;
@property (nonatomic, copy, nullable) NSString *mimeType;
@property (nonatomic, strong, nonnull) NSData *fileData;
@property (nonatomic, strong, nonnull) NSURL *fileURL;

+ (nonnull instancetype)formDataWithName:(nonnull NSString *)name fileData:(nonnull NSData *)fileData;

+ (nonnull instancetype)formDataWithName:(nonnull NSString *)name fileName:(nullable NSString *)fileName mimeType:(nullable NSString *)mimeType fileData:(nonnull NSData *)fileData;

+ (nonnull instancetype)formDataWithName:(nonnull NSString *)name fileURL:(nonnull NSURL *)fileURL;

+ (nonnull instancetype)formDataWithName:(nonnull NSString *)name fileName:(nullable NSString *)fileName mimeType:(nullable NSString *)mimeType fileURL:(nonnull NSURL *)fileURL;

@end
NS_ASSUME_NONNULL_END
