//
//  YUCISkyGenerator.m
//  Pods
//
//  Created by YuAo on 3/15/16.
//
//

#import "YUCISkyGenerator.h"
#import "YUCIFilterConstructor.h"

@implementation YUCISkyGenerator

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:NSStringFromClass([YUCISkyGenerator class])
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo,kCICategoryGenerator],
                                               kCIAttributeFilterDisplayName: @"Sky Generator"}];
            }
        }
    });
}

+ (CIColorKernel *)filterKernel {
    static CIColorKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCISkyGenerator class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
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

- (CIVector *)inputViewPointOffset {
    if (!_inputViewPointOffset) {
        _inputViewPointOffset = [CIVector vectorWithX:0 Y:0.9];
    }
    return _inputViewPointOffset;
}

- (CIVector *)inputSunPosition {
    if (!_inputSunPosition) {
        _inputSunPosition = [CIVector vectorWithX:0 Y:0.1 Z:-1.0];
    }
    return _inputSunPosition;
}

- (NSNumber *)inputSunIntensity {
    if (!_inputSunIntensity) {
        _inputSunIntensity = @30;
    }
    return _inputSunIntensity;
}

- (void)setDefaults {
    self.inputExtent = nil;
    self.inputViewPointOffset = nil;
    self.inputSunPosition = nil;
    self.inputSunIntensity = nil;
}

- (CIImage *)outputImage {
    return [[YUCISkyGenerator filterKernel] applyWithExtent:self.inputExtent.CGRectValue
                                                        arguments:@[self.inputExtent,self.inputViewPointOffset,self.inputSunPosition,self.inputSunIntensity]];
}

@end
