//
//  YUCIFilterConstructor.m
//  Pods
//
//  Created by YuAo on 1/23/16.
//
//

#import "YUCIFilterConstructor.h"

@implementation YUCIFilterConstructor

+ (instancetype)constructor {
    static YUCIFilterConstructor *constructor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        constructor = [[YUCIFilterConstructor alloc] initForSharedConstructor];
    });
    return constructor;
}

- (instancetype)initForSharedConstructor {
    if (self = [super init]) {
        
    }
    return self;
}

- (CIFilter *)filterWithName:(NSString *)name {
    return [[NSClassFromString(name) alloc] init];
}

@end
