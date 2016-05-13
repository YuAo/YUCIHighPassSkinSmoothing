//
//  YUCISurfaceBlur.m
//  Pods
//
//  Created by YuAo on 2/3/16.
//
//

#import "YUCISurfaceBlur.h"
#import "YUCIFilterUtilities.h"
#import "YUCIFilterConstructor.h"

@implementation YUCISurfaceBlur

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:NSStringFromClass([YUCISurfaceBlur class])
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo,kCICategoryBlur],
                                               kCIAttributeFilterDisplayName: @"Surface Blur"}];
            }
        }
    });
}

static NSDictionary *YUCISurfaceBlurKernels;

+ (CIKernel *)filterKernelForRadius:(NSInteger)radius {
    CIKernel *kernel = YUCISurfaceBlurKernels[@(radius)];
    
    if (kernel) {
        return kernel;
    } else {
        NSMutableArray *wights = [NSMutableArray array];
        for (NSInteger i = 0; i < radius; ++i) {
            double wight = YUCIGaussianDistributionPDF(i, radius);
            [wights addObject:@(wight)];
        }
        
        NSString *gaussianWeightsSetupProgram = @"";
        for (NSInteger i = 0; i < wights.count; ++i) {
            gaussianWeightsSetupProgram = [gaussianWeightsSetupProgram stringByAppendingFormat:@"GAUSSIAN_WEIGHTS[%@] = GAUSSIAN_WEIGHTS[%@] = %@; \n",@(radius - 1 - i),@(radius - 1 + i),wights[i]];
        }
        
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCISurfaceBlur class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernelString = [kernelString stringByReplacingOccurrencesOfString:@"MACRO_SAMPLES_COUNT" withString:@(radius * 2).stringValue];
        kernelString = [kernelString stringByReplacingOccurrencesOfString:@"MACRO_SETUP_GAUSSIAN_WEIGHTS" withString:gaussianWeightsSetupProgram];
        kernel = [CIKernel kernelWithString:kernelString];
        
        NSMutableDictionary *newKernels = [NSMutableDictionary dictionaryWithDictionary:YUCISurfaceBlurKernels];
        [newKernels setObject:kernel forKey:@(radius)];
        YUCISurfaceBlurKernels = newKernels.copy;
        
        return kernel;
    }
}

- (NSNumber *)inputRadius {
    if (!_inputRadius) {
        _inputRadius = @(10);
    }
    return _inputRadius;
}

- (NSNumber *)inputThreshold {
    if (!_inputThreshold) {
        _inputThreshold = @(10);
    }
    return _inputThreshold;
}

- (void)setDefaults {
    self.inputRadius = nil;
    self.inputThreshold = nil;
}

- (CIImage *)outputImage {
    if (!self.inputImage) {
        return nil;
    }
    
    if (self.inputRadius.integerValue <= 0 || self.inputThreshold.doubleValue < 0) {
        return self.inputImage;
    }
    
    CIKernel *kernel = [YUCISurfaceBlur filterKernelForRadius:[self.inputRadius integerValue]];
    return [kernel applyWithExtent:self.inputImage.extent
                       roiCallback:^CGRect(int index, CGRect destRect) {
                           return CGRectInset(destRect, -self.inputRadius.integerValue, -self.inputRadius.integerValue);
                       } arguments:@[self.inputImage.imageByClampingToExtent,@(self.inputThreshold.doubleValue/255.0 * 2.0)]];
}


@end
