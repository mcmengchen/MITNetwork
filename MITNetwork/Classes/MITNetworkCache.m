//
//  MITNetworkCache.m
//  Pods
//
//  Created by MENGCHEN on 2017/3/9.
//
//

#import "MITNetworkCache.h"
#import "YYCache.h"




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



#pragma mark create 创建缓存
- (YYCache *)cache{
    if (!_cache) {
        _cache = [YYCache cacheWithName:kMitCacheKey];
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


@end
