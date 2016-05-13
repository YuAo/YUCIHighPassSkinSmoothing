//
//  YUCIBilateralFilter.m
//  Pods
//
//  Created by YuAo on 2/2/16.
//
//

#import "YUCIBilateralFilter.h"
#import "YUCIFilterUtilities.h"

@implementation YUCIBilateralFilter

static NSDictionary *YUCIBilateralFilterKernels;

+ (NSInteger)sampleCountForRadius:(NSInteger)radius {
    CGFloat minimumWeightToFindEdgeOfSamplingArea = 1.0/256.0;
    radius = floor(sqrt(-2.0 * pow(radius, 2.0) * log(minimumWeightToFindEdgeOfSamplingArea * sqrt(2.0 * M_PI * pow(radius, 2.0))) ));
    if (radius % 2 == 0) {
        radius = radius - 1;
    }
    if (radius <= 0) {
        radius = 1;
    }
    return radius;
}

+ (CIKernel *)filterKernelForRadius:(NSInteger)radius {
    NSInteger sampleCount = [self sampleCountForRadius:radius];
    
    CIKernel *kernel = YUCIBilateralFilterKernels[@(sampleCount)];
    
    if (kernel) {
        return kernel;
    } else {
        double sigma = radius;
        
        double sum = 0;
        NSMutableArray *wights = [NSMutableArray array];
        for (NSInteger i = 0; i < (sampleCount + 1)/2; ++i) {
            double wight = YUCIGaussianDistributionPDF(i, sigma);
            if (i == 0) {
                sum += wight;
            } else {
                sum += wight * 2;
            }
            [wights addObject:@(wight)];
        }
        double scale = 1.0/sum;
        
        NSString *setupString = @"";
        for (NSInteger i = 0; i < wights.count; ++i) {
            setupString = [setupString stringByAppendingFormat:@"GAUSSIAN_WEIGHTS[%@] = %@; \n",@(i),@([wights[i] doubleValue] * scale)];
        }
        
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIBilateralFilter class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernelString = [kernelString stringByReplacingOccurrencesOfString:@"MACRO_GAUSSIAN_SAMPLES" withString:@(sampleCount).stringValue];
        kernelString = [kernelString stringByReplacingOccurrencesOfString:@"MACRO_SETUP_GAUSSIAN_WEIGHTS" withString:setupString];
        kernel = [CIKernel kernelWithString:kernelString];
        
        NSMutableDictionary *newKernels = [NSMutableDictionary dictionaryWithDictionary:YUCIBilateralFilterKernels];
        [newKernels setObject:kernel forKey:@(sampleCount)];
        YUCIBilateralFilterKernels = newKernels.copy;
        
        return kernel;
    }
}

- (NSNumber *)inputRadius {
    if (!_inputRadius) {
        _inputRadius = @(10);
    }
    return _inputRadius;
}

- (NSNumber *)inputTexelSpacingMultiplier {
    if (!_inputTexelSpacingMultiplier) {
        _inputTexelSpacingMultiplier = @(1.0);
    }
    return _inputTexelSpacingMultiplier;
}

- (NSNumber *)inputDistanceNormalizationFactor {
    if (!_inputDistanceNormalizationFactor) {
        _inputDistanceNormalizationFactor = @(5.0);
    }
    return _inputDistanceNormalizationFactor;
}

- (void)setDefaults {
    self.inputRadius = nil;
    self.inputTexelSpacingMultiplier = nil;
    self.inputDistanceNormalizationFactor = nil;
}

- (CIImage *)outputImage {
    if (!self.inputImage) {
        return nil;
    }
    
    CIKernel *kernel = [YUCIBilateralFilter filterKernelForRadius:[self.inputRadius integerValue]];
    CGFloat inset = -([self.class sampleCountForRadius:self.inputRadius.integerValue] * self.inputTexelSpacingMultiplier.doubleValue)/2.0;
    CIImage *horizontalPassResult = [kernel applyWithExtent:self.inputImage.extent
                                                roiCallback:^CGRect(int index, CGRect destRect) {
                                                    return CGRectInset(destRect, inset, 0);
                                                } arguments:@[self.inputImage,
                                                              [CIVector vectorWithX:[self.inputTexelSpacingMultiplier doubleValue] Y:0],
                                                              self.inputDistanceNormalizationFactor]];
    CIImage *verticalPassResult = [kernel applyWithExtent:horizontalPassResult.extent
                                              roiCallback:^CGRect(int index, CGRect destRect) {
                                                  return CGRectInset(destRect, 0, inset);
                                              } arguments:@[horizontalPassResult,
                                                            [CIVector vectorWithX:0 Y:[self.inputTexelSpacingMultiplier doubleValue]],
                                                            self.inputDistanceNormalizationFactor]];
    return verticalPassResult;
}

@end
