//
//  YUCICrossZoomTransition.m
//  Pods
//
//  Created by YuAo on 2/4/16.
//
//

#import "YUCICrossZoomTransition.h"
#import "YUCIFilterConstructor.h"

@implementation YUCICrossZoomTransition

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:NSStringFromClass([YUCICrossZoomTransition class])
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo,kCICategoryTransition],
                                               kCIAttributeFilterDisplayName: @"Cross Zoom Transition"}];
            }
        }
    });
}

+ (CIKernel *)filterKernel {
    static CIKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCICrossZoomTransition class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (NSNumber *)inputStrength {
    if (!_inputStrength) {
        _inputStrength = @(0.3);
    }
    return _inputStrength;
}

- (NSNumber *)inputTime {
    if (!_inputTime) {
        _inputTime = @(0.0);
    }
    return _inputTime;
}

- (void)setDefaults {
    self.inputStrength = nil;
    self.inputTime = nil;
}

- (CIImage *)outputImage {
    if (!self.inputImage || !self.inputTargetImage) {
        return nil;
    }
    
    CIVector *defaultInputExtent = [CIVector vectorWithCGRect:CGRectUnion(self.inputImage.extent, self.inputTargetImage.extent)];
    CIVector *extent = self.inputExtent?:defaultInputExtent;
    return [[YUCICrossZoomTransition filterKernel] applyWithExtent:extent.CGRectValue
                                                       roiCallback:^CGRect(int index, CGRect destRect) {
                                                           return extent.CGRectValue;
                                                       }
                                                         arguments:@[self.inputImage,self.inputTargetImage,self.inputStrength,extent,self.inputTime]];
}

@end
