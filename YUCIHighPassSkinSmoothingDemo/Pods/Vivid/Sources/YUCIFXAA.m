//
//  YUCIFXAA.m
//  Pods
//
//  Created by YuAo on 2/14/16.
//
//

#import "YUCIFXAA.h"
#import "YUCIFilterConstructor.h"

@implementation YUCIFXAA

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:NSStringFromClass([YUCIFXAA class])
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo],
                                               kCIAttributeFilterDisplayName: @"Fast Approximate Anti-Aliasing"}];
            }
        }
    });
}

+ (CIKernel *)filterKernel {
    static CIKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIFXAA class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (CIImage *)outputImage {
    if (!self.inputImage) {
        return nil;
    }
    
    return [[YUCIFXAA filterKernel] applyWithExtent:self.inputImage.extent
                                        roiCallback:^CGRect(int index, CGRect destRect) {
                                            return CGRectInset(destRect, -8, -8); //FXAA_SPAN_MAX
                                        } arguments:@[self.inputImage.imageByClampingToExtent]];
}

@end
