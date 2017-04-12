//
//  MITNetworkCookie.m
//  Pods
//
//  Created by Meng,Chen on 2017/4/9.
//
//

#import "MITNetworkCookie.h"
#import "NSMutableArray+MITNetworkHelper.h"
#import "NSArray+MITNetworkHelper.h"
#import "NSMutableDictionary+MITNetworkHelper.h"
#import "MITNetworkConfig.h"
#define MIT_USER_DEFAULT [NSUserDefaults standardUserDefaults]


NSString * kDefaultCookie = @"MIT_Cookies";

@implementation MITNetworkCookie
+(void)saveCookies:(NSArray*)cookies {
    NSArray *lastCookies = [MIT_USER_DEFAULT objectForKey:kDefaultCookie];
    NSMutableArray *currentCookies = [NSMutableArray array];
    if (lastCookies&&lastCookies.count>0) {
        [currentCookies addObjectsFromArray:lastCookies];
    }
    if (cookies&&cookies.count>0) {
        for (int i=0; i<cookies.count; i++) {
            NSHTTPCookie *cookie = [cookies objectAtIndexCheck:i];
            NSString *name  = cookie.name;
            NSString *value = cookie.value;
            NSDictionary *saveDic = [NSDictionary dictionaryWithObjectsAndKeys:value,@"value",name,@"name", nil];
            if (lastCookies&&lastCookies.count>0) {
                BOOL isExist = NO;
                for (int j=0; j<lastCookies.count; j++) {
                    NSDictionary *lastDic = [lastCookies objectAtIndexCheck:j];
                    NSString *lastName = [lastDic objectForKey:@"name"];
                    if ([lastName isEqualToString:name]) {
                        if ([value isEqualToString:@"deleted"]) {
                            [currentCookies removeObject:lastDic];
                        } else {
                            [currentCookies removeObject:lastDic];
                            [currentCookies addObjectCheck:saveDic];
                        }
                        isExist = YES;
                    } else if ([value isEqualToString:@"deleted"]){
                        isExist = YES;
                    }
                }
                if (!isExist) {
                    [currentCookies addObjectCheck:saveDic];
                }
            } else {
                if ([value isEqualToString:@"deleted"]) {
                    continue;
                } else {
                    [currentCookies addObjectCheck:saveDic];
                }
            }
        }
        [MIT_USER_DEFAULT setObject:currentCookies forKey:kDefaultCookie];
        [MIT_USER_DEFAULT synchronize];
    }
}

#pragma mark action 删除所有 cookie
+ (void)deleteAllCookies {
    NSArray * lastCookies = [MIT_USER_DEFAULT objectForKey:kDefaultCookie];
    NSMutableArray * currentCookies = [NSMutableArray arrayWithArray:lastCookies];
    if (lastCookies&&lastCookies.count>0) {
        for (NSDictionary * cookie in lastCookies) {
            [currentCookies removeObject:cookie];
        }
        [MIT_USER_DEFAULT setObject:currentCookies forKey:kDefaultCookie];
        [MIT_USER_DEFAULT synchronize];
    }
}

#pragma mark action 删除指定 cookie
+ (void)deleteCookieForName:(NSString *)cookieName{
    NSArray * lastCookies = [MIT_USER_DEFAULT objectForKey:kDefaultCookie];
    NSMutableArray * currentCookies = [NSMutableArray arrayWithArray:lastCookies];
    if (lastCookies&&lastCookies.count>0) {
        for (NSDictionary * cookie in lastCookies) {
            NSString * name = [cookie objectForKey:@"name"];
            if (name&&name.length>0&&[name isEqualToString:cookieName]) {
                [currentCookies removeObject:cookie];
            }
        }
        [MIT_USER_DEFAULT setObject:currentCookies forKey:kDefaultCookie];
        [MIT_USER_DEFAULT synchronize];
    }
}


#pragma mark action 获取所有 cookies
+ (NSArray*)getAllCookies {
    NSArray *localCookies = [MIT_USER_DEFAULT objectForKey:kDefaultCookie];
    NSMutableArray *postCookies = [NSMutableArray array];
    BOOL hasDefaultCookie = false;
    if (localCookies&&localCookies.count>0) {
        for (int i=0; i<localCookies.count; i++) {
            NSDictionary *cookie = [localCookies objectAtIndexCheck:i];
            NSString * name = [cookie objectForKey:@"name"];
            NSString * value = [cookie objectForKey:@"value"];
            if ([name isEqualToString:[[MITNetworkConfig defaultConfig] cookieModel].cookieName]) {
                hasDefaultCookie = true;
            }
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setValue:name forKey:NSHTTPCookieName];
            [dic setValue:value forKey:NSHTTPCookieValue];
            [dic setValue:@"" forKey:NSHTTPCookieDomain];
            [dic setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
            [dic setValue:@"/" forKey:NSHTTPCookiePath];
            NSHTTPCookie *postCookie = [[NSHTTPCookie alloc] initWithProperties:dic];
            [postCookies addObjectCheck:postCookie];
        }
    }
    //如果没有默认的cookie，添加默认的cookie
    if (!hasDefaultCookie) {
        [self getDefaultCookie:[[MITNetworkConfig defaultConfig] cookieModel]];
    }
    
    if (postCookies.count>0) {
        return postCookies;
    }
    else {
        return nil;
    }
}


#pragma mark action 获取默认 cookie（默认外界设定 cookie 的参数通过 config 类来设定）
+ (NSHTTPCookie *)getDefaultCookie:(MITNetworkCookieModel *)model {
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObjectCheck:model.cookieName forKey:NSHTTPCookieName];
    [cookieProperties setObjectCheck:model.cookieValue forKey:NSHTTPCookieValue];
    [cookieProperties setObjectCheck:model.cookieDomain forKey:NSHTTPCookieDomain];
    [cookieProperties setObjectCheck:model.cookiePath forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    return cookie;
}
@end
