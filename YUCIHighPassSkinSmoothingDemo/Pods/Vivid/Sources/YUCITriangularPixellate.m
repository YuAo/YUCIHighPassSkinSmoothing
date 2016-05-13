//
//  YUCITriangularPixellate.m
//  Pods
//
//  Created by YuAo on 2/9/16.
//
//

#import "YUCITriangularPixellate.h"
#import "YUCIFilterConstructor.h"

@implementation YUCITriangularPixellate

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:NSStringFromClass([YUCITriangularPixellate class])
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo,kCICategoryStylize],
                                               kCIAttributeFilterDisplayName: @"Triangular Pixellate"}];
            }
        }
    });
}

+ (CIKernel *)filterKernel {
    static CIKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCITriangularPixellate class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (NSNumber *)inputScale {
    if (!_inputScale) {
        _inputScale = @(20);
    }
    return _inputScale;
}

- (NSNumber *)inputVertexAngle {
    if (!_inputVertexAngle) {
        _inputVertexAngle = @(M_PI/2.0);
    }
    return _inputVertexAngle;
}

- (CIVector *)inputCenter {
    if (!_inputCenter) {
        _inputCenter = [CIVector vectorWithX:0 Y:0];
    }
    return _inputCenter;
}

- (void)setDefaults {
    self.inputScale = nil;
    self.inputVertexAngle = nil;
    self.inputCenter = nil;
}

- (CIImage *)outputImage {
    if (!self.inputImage) {
        return nil;
    }
    
    CGFloat tanHalfInputAngle = tan(self.inputVertexAngle.floatValue/2.0);
    return [[YUCITriangularPixellate filterKernel] applyWithExtent:self.inputImage.extent
                                                       roiCallback:^CGRect(int index, CGRect destRect) {
                                                           return CGRectInset(destRect, -self.inputScale.floatValue, -self.inputScale.floatValue/2.0 * tanHalfInputAngle);
                                                       } arguments:@[self.inputImage.imageByClampingToExtent,self.inputCenter,self.inputScale,@(tanHalfInputAngle)]];
}

@end
