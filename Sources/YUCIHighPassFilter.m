//
//  YUCIHighPassFilter.m
//  Pods
//
//  Created by YuAo on 1/22/16.
//
//

#import "YUCIHighPassFilter.h"
#import "YUCIFilterConstructor.h"

NSString * const YUCIHighPass = @"YUCIHighPassFilter";

@implementation YUCIHighPassFilter

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:YUCIHighPass
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo]}];
            }
        }
    });
}

+ (CIColorKernel *)filterKernel {
    static CIColorKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIHighPassFilter class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
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

- (CIImage *)outputImage {
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setValue:self.inputRadius forKey:kCIInputRadiusKey];
    [blurFilter setValue:self.inputImage forKey:kCIInputImageKey];
    return [[YUCIHighPassFilter filterKernel] applyWithExtent:self.inputImage.extent arguments:@[self.inputImage,blurFilter.outputImage]];
}

@end
