//
//  MITNetworkCache.m
//  Pods
//
//  Created by MENGCHEN on 2017/3/9.
//
//

#import "MITNetworkCache.h"
#import "YYCache.h"

#import "MITNetworkConfig.h"


static NSString * kMitCacheKey = @"kMitCacheKey";

@interface MITNetworkCache()



/** 缓存 */
@property(nonatomic, strong)YYCache * cache;

@end

@implementation MITNetworkCache


+(instancetype)cache{
    static MITNetworkCache * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

//默认时间限制（默认15天）
static NSTimeInterval kDefaultAgeLimit = 60*60*24*15;
//默认消耗限制(默认50M)
static NSUInteger kDefaultCostLimit = 50*1024*1024;
#pragma mark create 创建缓存
- (YYCache *)cache{
    if (!_cache) {
        _cache = [YYCache cacheWithName:kMitCacheKey];
        if ([MITNetworkConfig defaultConfig].cacheAgeLimit>0) {
            _cache.memoryCache.costLimit = [MITNetworkConfig defaultConfig].cacheAgeLimit;
        }else{
            _cache.memoryCache.costLimit = kDefaultCostLimit;
        }
        if ([MITNetworkConfig defaultConfig].cacheAgeLimit>0) {
            _cache.memoryCache.ageLimit = [MITNetworkConfig defaultConfig].cacheAgeLimit;
        }else{
            _cache.diskCache.ageLimit = kDefaultAgeLimit;
        }
    }
    return _cache;
}


#pragma mark action 设置缓存
+ (void)mit_setCache:(id)obj URL:(NSString *)url params:(NSDictionary *)param{
    [[MITNetworkCache cache]mit_setCache:obj URL:url params:param];
}
- (void)mit_setCache:(id)obj URL:(NSString *)url params:(NSDictionary *)param{
    NSString * cacheKey = [self cacheKey:url params:param];
    [self.cache setObject:obj forKey:cacheKey];
}

#pragma mark action 获取 cache
+ (id)mit_CacheWithURL:(NSString *)url params:(NSDictionary *)param{
    return [[MITNetworkCache cache] mit_CacheWithURL:url params:param];
}

- (id)mit_CacheWithURL:(NSString *)url params:(NSDictionary *)param{
    NSString * cacheKey = [self cacheKey:url params:param];
    return [self.cache objectForKey:cacheKey];
}

#pragma mark action 获取 key
- (NSString * )cacheKey:(NSString *)url params:(NSDictionary *)params{
    NSAssert(url, @"没有 URL");
    if (!url) {
        return nil;
    }
    if (!params) {
        return url;
    }
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSString *paraString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@",url,paraString];
    return cacheKey;
}

#pragma mark action 移除所有缓存
+ (void)removeAllCache{
    [[MITNetworkCache cache] removeAllCache];
}

- (void)removeAllCache{
    [_cache removeAllObjects];
}

#pragma mark action 获取所有缓存大小
+ (NSUInteger)getAllHttpCacheSize{
    return [[MITNetworkCache cache].cache.memoryCache totalCost]+[[MITNetworkCache cache].cache.diskCache totalCost];
}

#pragma mark action 获取磁盘缓存大小
+ (NSUInteger)getDiskCacheSize{
    return [[MITNetworkCache cache].cache.diskCache totalCost];
}

#pragma mark action 获取内存缓存大小
+ (NSUInteger)getMemoryCacheSize{
    return [[MITNetworkCache cache].cache.memoryCache totalCost];
}



@end
