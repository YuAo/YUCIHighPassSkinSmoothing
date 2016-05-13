//
//  YUCIBlobsGenerator.m
//  Pods
//
//  Created by YuAo on 2/6/16.
//
//

#import "YUCIBlobsGenerator.h"
#import "YUCIFilterConstructor.h"

@implementation YUCIBlobsGenerator

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:NSStringFromClass([YUCIBlobsGenerator class])
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo,kCICategoryGenerator],
                                               kCIAttributeFilterDisplayName: @"Blobs Generator"}];
            }
        }
    });
}

+ (CIColorKernel *)filterKernel {
    static CIColorKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIBlobsGenerator class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIColorKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (CIVector *)inputExtent {
    if (!_inputExtent) {
        _inputExtent = [CIVector vectorWithCGRect:CGRectMake(0, 0, 640, 480)];
    }
    return _inputExtent;
}

- (NSNumber *)inputTime {
    if (!_inputTime) {
        _inputTime = @(0);
    }
    return _inputTime;
}

- (void)setDefaults {
    self.inputExtent = nil;
    self.inputTime = nil;
}

- (CIImage *)outputImage {
    return [[YUCIBlobsGenerator filterKernel] applyWithExtent:self.inputExtent.CGRectValue
                                                    arguments:@[self.inputExtent,self.inputTime]];
}

@end
