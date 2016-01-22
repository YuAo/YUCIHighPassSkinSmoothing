//
//  YUCIHighPassFilter.m
//  Pods
//
//  Created by YuAo on 1/22/16.
//
//

#import "YUCIHighPassFilter.h"

@implementation YUCIHighPassFilter

+ (CIColorKernel *)filterKernel {
    static CIColorKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIHighPassFilter class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIColorKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (CIImage *)outputImage {
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setValue:self.inputRadius ?: @(1.0) forKey:kCIInputRadiusKey];
    [blurFilter setValue:self.inputImage forKey:kCIInputImageKey];
    return [[YUCIHighPassFilter filterKernel] applyWithExtent:self.inputImage.extent arguments:@[self.inputImage,blurFilter.outputImage]];
}

@end
