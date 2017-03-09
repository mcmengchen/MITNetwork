//
//  MITNetworkCache.h
//  Pods
//
//  Created by MENGCHEN on 2017/3/9.
//
//

#import <Foundation/Foundation.h>

@interface MITNetworkCache : NSObject



//设置缓存
+ (void)mit_setCache:(id)obj URL:(NSString *)url params:(NSDictionary *)param;

//获取缓存
+ (id)mit_CacheWithURL:(NSString * )url params:(NSDictionary *)param;

/**
 *  获取网络缓存的总大小 bytes(字节)
 */
+ (NSInteger)getAllHttpCacheSize;


/**
 *  删除所有网络缓存,
 */
+ (void)removeAllCache;
@end
