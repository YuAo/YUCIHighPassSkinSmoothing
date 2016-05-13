//
//  YUCIColorLookupFilter.m
//  CoreImageSkinEnhancementFilter
//
//  Created by YuAo on 1/20/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

#import "YUCIColorLookup.h"
#import "YUCIFilterConstructor.h"

@implementation YUCIColorLookup

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:NSStringFromClass([YUCIColorLookup class])
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo,kCICategoryColorEffect,kCICategoryInterlaced,kCICategoryNonSquarePixels],
                                               kCIAttributeFilterDisplayName: @"Color Lookup"}];
            }
        }
    });
}

+ (CIKernel *)filterKernel {
    static CIKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIColorLookup class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (NSNumber *)inputIntensity {
    if (!_inputIntensity) {
        _inputIntensity = @(1.0);
    }
    return _inputIntensity;
}

- (CIImage *)inputColorLookupTable {
    if (!_inputColorLookupTable) {
        _inputColorLookupTable = [CIImage imageWithContentsOfURL:[[NSBundle bundleForClass:self.class] URLForResource:@"YUCIColorLookupTableDefault" withExtension:@"png"]];
    }
    return _inputColorLookupTable;
}

- (void)setDefaults {
    self.inputIntensity = nil;
    self.inputColorLookupTable = nil;
}

- (CIImage *)outputImage {
    if (!self.inputImage) {
        return nil;
    }
    
    return [[YUCIColorLookup filterKernel] applyWithExtent:self.inputImage.extent
                                               roiCallback:^CGRect(int index, CGRect destRect) {
                                                   if (index == 0) {
                                                       return destRect;
                                                   } else {
                                                       return self.inputColorLookupTable.extent;
                                                   }
                                               }
                                                 arguments:@[self.inputImage,self.inputColorLookupTable,self.inputIntensity]];
}

@end
