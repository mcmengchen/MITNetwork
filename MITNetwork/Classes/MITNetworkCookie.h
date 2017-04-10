//
//  MITNetworkCookie.h
//  Pods
//
//  Created by Meng,Chen on 2017/4/9.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MITNetworkCookieModel : NSObject

/* cookie Name */
@property (nonatomic, strong) NSString * cookieName;
/* cookie Domain */
@property (nonatomic, strong) NSString * cookieDomain;
/* cookie Path */
@property (nonatomic, strong) NSString * cookiePath;
/* cookie Value */
@property (nonatomic, strong) NSString * cookieValue;



@end


@interface MITNetworkCookie : NSObject

+ (void)saveCookies:(NSArray*)cookies;
+ (void)deleteAllCookies;
+ (NSArray*)getCookies;


@end
