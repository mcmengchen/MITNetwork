//
//  NSMutableDictionary+MITNetworkHelper.m
//  Pods
//
//  Created by Meng,Chen on 2017/4/10.
//
//

#import "NSMutableDictionary+MITNetworkHelper.h"

@implementation NSMutableDictionary (MITNetworkHelper)
- (void)setObjectCheck:(id)anObject forKey:(id <NSCopying>)aKey
{
    if (aKey == nil) {
        NSLog(@"%@ setObjectCheck: aKey 为 nil",self);
        return;
    }
    
    if (anObject == nil) {
        NSLog(@"%@ setObjectCheck: anObject 为 nil",self);
        return;
    }
    
    [self setObject:anObject forKey:aKey];
}
@end
