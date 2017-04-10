//
//  NSArray+MITNetworkHelper.m
//  Pods
//
//  Created by Meng,Chen on 2017/4/9.
//
//

#import "NSArray+MITNetworkHelper.h"

@implementation NSArray (MITNetworkHelper)
- (id)objectAtIndexCheck:(NSUInteger)index
{
    if (index >= [self count]) {
        return nil;
    }
    
    id value = [self objectAtIndex:index];
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}
- (void)addObjectCheck:(id)anObject
{
    if (anObject == nil) {
        NSLog(@"NSArray addObject: anObject 为 nil");
        return;
    }
    [self addObject:anObject];
}
@end
