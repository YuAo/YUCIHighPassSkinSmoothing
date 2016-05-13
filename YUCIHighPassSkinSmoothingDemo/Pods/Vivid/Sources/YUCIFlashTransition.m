//
//  YUCIFlashTransition.m
//  Pods
//
//  Created by YuAo on 2/4/16.
//
//

#import "YUCIFlashTransition.h"
#import "YUCIFilterConstructor.h"

@implementation YUCIFlashTransition

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:NSStringFromClass([YUCIFlashTransition class])
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo,kCICategoryTransition],
                                               kCIAttributeFilterDisplayName: @"Flash Transition"}];
            }
        }
    });
}

+ (CIColorKernel *)filterKernel {
    static CIColorKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIFlashTransition class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIColorKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (NSNumber *)inputFlashPhase {
    if (!_inputFlashPhase) {
        _inputFlashPhase = @(0.6);
    }
    return _inputFlashPhase;
}

- (NSNumber *)inputFlashIntensity {
    if (!_inputFlashIntensity) {
        _inputFlashIntensity = @(3.0);
    }
    return _inputFlashIntensity;
}

- (NSNumber *)inputFlashZoom {
    if (!_inputFlashZoom) {
        _inputFlashZoom = @(0.5);
    }
    return _inputFlashZoom;
}

- (NSNumber *)inputTime {
    if (!_inputTime) {
        _inputTime = @(0);
    }
    return _inputTime;
}

- (void)setDefaults {
    self.inputFlashPhase = nil;
    self.inputFlashIntensity = nil;
    self.inputFlashZoom = nil;
    self.inputTime = nil;
}

- (CIImage *)outputImage {
    if (!self.inputImage || !self.inputTargetImage) {
        return nil;
    }
    
    CIVector *defaultInputExtent = [CIVector vectorWithCGRect:CGRectUnion(self.inputImage.extent, self.inputTargetImage.extent)];
    CIVector *extent = self.inputExtent?:defaultInputExtent;
    return [[YUCIFlashTransition filterKernel] applyWithExtent:extent.CGRectValue
                                                     arguments:@[self.inputImage,self.inputTargetImage,self.inputFlashPhase,self.inputFlashIntensity,self.inputFlashZoom,extent,self.inputTime]];
}

@end
