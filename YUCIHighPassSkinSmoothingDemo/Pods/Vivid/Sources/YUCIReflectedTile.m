//
//  YUCIReflectTile.m
//  Pods
//
//  Created by YuAo on 2/16/16.
//
//

#import "YUCIReflectedTile.h"
#import "YUCIFilterConstructor.h"
#import "YUCIReflectedTileROICalculator.h"

@implementation YUCIReflectedTile

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:NSStringFromClass([YUCIReflectedTile class])
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo,kCICategoryTileEffect],
                                               kCIAttributeFilterDisplayName: @"Reflected Tile"}];
            }
        }
    });
}

+ (CIWarpKernel *)filterKernel {
    static CIWarpKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIReflectedTile class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIWarpKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (NSNumber *)inputMode {
    if (!_inputMode) {
        _inputMode = @(YUCIReflectedTileModeReflectWithoutBorder);
    }
    return _inputMode;
}

- (void)setDefaults {
    self.inputMode = nil;
}

- (CIImage *)outputImage {
    if (!self.inputImage) {
        return nil;
    }
    
    CGRect inputExtent = self.inputImage.extent;
    return [[YUCIReflectedTile filterKernel] applyWithExtent:CGRectInfinite
                                                 roiCallback:^CGRect(int index, CGRect destRect) {
                                                     return [YUCIReflectedTileROICalculator ROIForDestinationRect:destRect inputImageExtent:inputExtent mode:self.inputMode.integerValue];
                                                 }
                                                  inputImage:self.inputImage
                                                   arguments:@[self.inputMode,[CIVector vectorWithCGRect:self.inputImage.extent]]];
}

@end
