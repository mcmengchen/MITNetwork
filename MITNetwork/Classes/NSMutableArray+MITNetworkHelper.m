//
//  NSMutableArray+MITNetworkHelper.m
//  Pods
//
//  Created by Meng,Chen on 2017/4/9.
//
//

#import "NSMutableArray+MITNetworkHelper.h"

@implementation NSMutableArray (MITNetworkHelper)
- (void)addObjectCheck:(id)anObject
{
    if (anObject == nil) {
        NSLog(@"NSArray addObject: anObject 为 nil");
        return;
    }
    [self addObject:anObject];
}
@end
