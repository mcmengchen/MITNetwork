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


@end
