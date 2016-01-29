//
//  YUCIColorLookupFilter.m
//  CoreImageSkinEnhancementFilter
//
//  Created by YuAo on 1/20/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

#import "YUCIColorLookup.h"

@implementation YUCIColorLookup

- (NSNumber *)inputIntensity {
    if (!_inputIntensity) {
        _inputIntensity = @(1.0);
    }
    return _inputIntensity;
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

- (CIImage *)outputImage {
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
