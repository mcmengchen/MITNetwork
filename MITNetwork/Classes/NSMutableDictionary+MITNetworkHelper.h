//
//  NSMutableDictionary+MITNetworkHelper.h
//  Pods
//
//  Created by Meng,Chen on 2017/4/10.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (MITNetworkHelper)
- (void)setObjectCheck:(id)anObject forKey:(id <NSCopying>)aKey;
@end
