//
//  MITAppDelegate.m
//  MITNetwork
//
//  Created by mcmengchen on 03/07/2017.
//  Copyright (c) 2017 mcmengchen. All rights reserved.
//

#import "MITAppDelegate.h"
#import <MITNetwork/MITNetwork.h>
@implementation MITAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:@"2045436852"];
    [self setupDefaultNetConfig];
    return YES;
}
- (void)setupDefaultNetConfig{
    MITNetworkConfig *networkConfig  = [MITNetworkConfig defaultConfig];
    networkConfig.hostUrl = @"https://api.weibo.com/2";
    networkConfig.responseSerializer = MITNET_RESPONSE_SERIALIZERTYPE_JSON;
    networkConfig.enableDebug = true;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class])
    {
        //        ProvideMessageForWeiboViewController *controller = [[[ProvideMessageForWeiboViewController alloc] init] autorelease];
        //        [self.viewController presentModalViewController:controller animated:YES];
    }
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        NSString *title = @"发送结果";
        NSString *message = [NSString stringWithFormat:@"响应状态: %ld\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",
                             (long)response.statusCode, response.userInfo, response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        WBAuthorizeResponse *authorizeResponse = (WBAuthorizeResponse*)response;
        NSUserDefaults*standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject:[authorizeResponse accessToken] forKey:@"RBAccessToken"];
        [standardUserDefaults setObject:[authorizeResponse expirationDate] forKey:@"RBExpirationDate"];
        [standardUserDefaults setObject:[authorizeResponse refreshToken] forKey:@"RBRefreshToken"];
        [standardUserDefaults setObject:[authorizeResponse userID] forKey:@"RBuserID"];
        if ([standardUserDefaults synchronize]) {
            NSLog(@"写入数据成功");
        };
        
        
    }
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

@end
