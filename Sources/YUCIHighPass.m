//
//  YUCIHighPassFilter.m
//  Pods
//
//  Created by YuAo on 1/22/16.
//
//

#import "YUCIHighPass.h"
#import "YUCIFilterConstructor.h"

@implementation YUCIHighPass

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:NSStringFromClass([YUCIHighPass class])
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo],
                                               kCIAttributeFilterDisplayName: @"High Pass"}];
            }
        }
    });
}

+ (CIColorKernel *)filterKernel {
    static CIColorKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIHighPass class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIColorKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (NSNumber *)inputRadius {
    if (!_inputRadius) {
        _inputRadius = @(1.0);
    }
    return _inputRadius;
}

- (void)setDefaults {
    self.inputRadius = nil;
}

- (CIImage *)outputImage {
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setValue:self.inputImage.imageByClampingToExtent forKey:kCIInputImageKey];
    [blurFilter setValue:self.inputRadius forKey:kCIInputRadiusKey];
    return [[YUCIHighPass filterKernel] applyWithExtent:self.inputImage.extent arguments:@[self.inputImage,blurFilter.outputImage]];
}

@end
