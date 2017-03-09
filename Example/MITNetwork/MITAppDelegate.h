//
//  MITAppDelegate.h
//  MITNetwork
//
//  Created by mcmengchen on 03/07/2017.
//  Copyright (c) 2017 mcmengchen. All rights reserved.
//

@import UIKit;
#import "WeiboSDK.h"

@interface MITAppDelegate : UIResponder <UIApplicationDelegate,WeiboSDKDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
