//
//  YUCIStarNestGenerator.m
//  Pods
//
//  Created by YuAo on 2/4/16.
//
//

#import "YUCIStarfieldGenerator.h"
#import "YUCIFilterConstructor.h"

@implementation YUCIStarfieldGenerator

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:NSStringFromClass([YUCIStarfieldGenerator class])
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo,kCICategoryGenerator],
                                               kCIAttributeFilterDisplayName: @"Starfield Generator"}];
            }
        }
    });
}

+ (CIColorKernel *)filterKernel {
    static CIColorKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIStarfieldGenerator class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
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

- (CIVector *)inputRotation {
    if (!_inputRotation) {
        _inputRotation = [CIVector vectorWithX:0 Y:0];
    }
    return _inputRotation;
}

- (void)setDefaults {
    self.inputExtent = nil;
    self.inputTime = nil;
    self.inputRotation = nil;
}

- (CIImage *)outputImage {
    return [[YUCIStarfieldGenerator filterKernel] applyWithExtent:self.inputExtent.CGRectValue
                                                        arguments:@[self.inputExtent,self.inputTime,self.inputRotation]];
}

@end
