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


#define MIT_USER_DEFAULT [NSUserDefaults standardUserDefaults]


const NSString * kDefaultCookie = @"MIT_Cookies";

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
                        }
                        else {
                            [currentCookies removeObject:lastDic];
                            [currentCookies addObjectCheck:saveDic];
                        }
                        
                        isExist = YES;
                    }
                    else if ([value isEqualToString:@"deleted"]){
                        isExist = YES;
                    }
                }
                if (!isExist) {
                    
                    [currentCookies addObjectCheck:saveDic];
                }
            }
            else {
                if ([value isEqualToString:@"deleted"]) {
                    continue;
                }
                else {
                    [currentCookies addObjectCheck:saveDic];
                }
            }
        }
        
        [MIT_USER_DEFAULT setObject:currentCookies forKey:kDefaultCookie];
        [MIT_USER_DEFAULT synchronize];
    }
}

+(void)deleteAllCookies {
    NSArray *lastCookies = [MIT_USER_DEFAULT objectForKey:kDefaultCookie];
    NSMutableArray *currentCookies = [NSMutableArray array];
    if (lastCookies&&lastCookies.count>0) {
        [currentCookies addObjectsFromArray:lastCookies];
        for (int i=0; i<lastCookies.count; i++) {
            NSDictionary *cookie = [lastCookies objectAtIndexCheck:i];
            NSString *name = [cookie objectForKey:@"name"];
            if ([name isEqualToString:@"BDUSS"]) {
                [currentCookies removeObject:cookie];
                break;
            }
        }
        
        [MIT_USER_DEFAULT setObject:currentCookies forKey:kDefaultCookie];
        [MIT_USER_DEFAULT synchronize];
    }
}

+(NSArray*)getCookies {
    NSArray *cookies = [MIT_USER_DEFAULT objectForKey:kDefaultCookie];
    NSMutableArray *postCookies = [NSMutableArray array];
    BOOL hasBDUSS = false;
    if (cookies&&cookies.count>0) {
        for (int i=0; i<cookies.count; i++) {
            NSDictionary *cookie = [cookies objectAtIndexCheck:i];
            NSString *name = [cookie objectForKey:@"name"];
            NSString *value = [cookie objectForKey:@"value"];
            
            if ([name isEqualToString:@"BDUSS"]) {
                hasBDUSS = YES;
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
    
//    if (BDHKIsLogin&&!hasBDUSS) {
//        [postCookies addObjectCheck:[MITNetworkCookie getCookie:[BDHKPassportService sharedInstance].passportBduss]];
//    }
    
    if (postCookies.count>0) {
        return postCookies;
    }
    else {
        return nil;
    }
}

+(NSHTTPCookie *)getCookie:(NSString *)value {
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObjectCheck:@"BDUSS" forKey:NSHTTPCookieName];
    [cookieProperties setObjectCheck:value forKey:NSHTTPCookieValue];
    [cookieProperties setObjectCheck:@"hao123.com" forKey:NSHTTPCookieDomain];
    [cookieProperties setObjectCheck:@"/" forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    return cookie;
}
@end
