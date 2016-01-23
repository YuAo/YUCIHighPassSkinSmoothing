//
//  YUCoreImageSkinEnhancementFilter.m
//  CoreImageSkinEnhancementFilter
//
//  Created by YuAo on 1/19/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

#import "YUCIHighPassSkinSmoothingFilter.h"
#import "YUCIRGBToneCurveFilter.h"
#import "YUCIHighPassFilter.h"
#import "YUCIFilterConstructor.h"

#pragma mark - YUCIGreenBlueChannelOverlayBlendFilter

@interface YUCIGreenBlueChannelOverlayBlendFilter : CIFilter

@property (nonatomic,strong) CIImage *inputImage;

@end

@implementation YUCIGreenBlueChannelOverlayBlendFilter

+ (CIColorKernel *)filterKernel {
    static CIColorKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIGreenBlueChannelOverlayBlendFilter class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIColorKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (CIImage *)outputImage {
    return [[YUCIGreenBlueChannelOverlayBlendFilter filterKernel] applyWithExtent:self.inputImage.extent arguments:@[self.inputImage]];
}

@end

#pragma mark - YUCIDermabrasionGaussianHighpassWithHardLightFilter

@interface YUCIDermabrasionHardLightFilter : CIFilter

@property (nonatomic,strong) CIImage *inputImage;

@end

@implementation YUCIDermabrasionHardLightFilter

+ (CIColorKernel *)filterKernel {
    static CIColorKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIDermabrasionHardLightFilter class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIColorKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (CIImage *)outputImage {
    return [[YUCIDermabrasionHardLightFilter filterKernel] applyWithExtent:self.inputImage.extent arguments:@[self.inputImage]];
}

@end

#pragma mark - YUCIHighpassDermabrasionRangeSelectionFilter

@interface YUCIHighPassDermabrasionRangeSelectionFilter: CIFilter

@property (nonatomic,strong) CIImage *inputImage;

@property (nonatomic,copy) NSNumber *inputRadius;

@end

@implementation YUCIHighPassDermabrasionRangeSelectionFilter

- (CIImage *)outputImage {
    CIFilter *exposureFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
    [exposureFilter setValue:self.inputImage forKey:kCIInputImageKey];
    [exposureFilter setValue:@(-1.0) forKey:kCIInputEVKey];
    
    YUCIGreenBlueChannelOverlayBlendFilter *channelOverlayFilter = [[YUCIGreenBlueChannelOverlayBlendFilter alloc] init];
    channelOverlayFilter.inputImage = exposureFilter.outputImage;
    
    YUCIHighPassFilter *highPassFilter = [[YUCIHighPassFilter alloc] init];
    highPassFilter.inputImage = channelOverlayFilter.outputImage;
    highPassFilter.inputRadius = self.inputRadius;
    
    YUCIDermabrasionHardLightFilter *hardLightFilter = [[YUCIDermabrasionHardLightFilter alloc] init];
    hardLightFilter.inputImage = highPassFilter.outputImage;
    return hardLightFilter.outputImage;
}

@end

#pragma mark - YUCISkinEnhancementFilter

NSString * const YUCIHighPassSkinSmoothing = @"YUCIHighPassSkinSmoothingFilter";

@interface YUCIHighPassSkinSmoothingFilter ()

@property (nonatomic,strong) YUCIRGBToneCurveFilter *skinToneCurveFilter;

@end

@implementation YUCIHighPassSkinSmoothingFilter

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:YUCIHighPassSkinSmoothing
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo]}];
            }
        }
    });
}

- (NSNumber *)inputAmount {
    if (!_inputAmount) {
        _inputAmount = @(0.75);
    }
    return _inputAmount;
}

- (NSNumber *)inputRadius {
    if (!_inputRadius) {
        _inputRadius = @(8.0);
    }
    return _inputRadius;
}

- (YUCIRGBToneCurveFilter *)skinToneCurveFilter {
    if (!_skinToneCurveFilter) {
        _skinToneCurveFilter = [[YUCIRGBToneCurveFilter alloc] init];
        _skinToneCurveFilter.rgbCompositeControlPoints = @[[CIVector vectorWithX:0 Y:0],
                                                           [CIVector vectorWithX:120/255.0 Y:146/255.0],
                                                           [CIVector vectorWithX:1.0 Y:1.0]];
    }
    return _skinToneCurveFilter;
}

- (void)setInputToneCurveControlPoints:(NSArray<CIVector *> *)inputToneCurveControlPoints {
    self.skinToneCurveFilter.rgbCompositeControlPoints = inputToneCurveControlPoints;
}

- (NSArray<CIVector *> *)inputToneCurveControlPoints {
    return self.skinToneCurveFilter.rgbCompositeControlPoints;
}

- (CIImage *)outputImage {
    YUCIHighPassDermabrasionRangeSelectionFilter *rangeSelectionFilter = [[YUCIHighPassDermabrasionRangeSelectionFilter alloc] init];
    rangeSelectionFilter.inputRadius = self.inputRadius;
    rangeSelectionFilter.inputImage = self.inputImage;
    
    YUCIRGBToneCurveFilter *skinToneCurveFilter = self.skinToneCurveFilter;
    skinToneCurveFilter.inputImage = self.inputImage;
    skinToneCurveFilter.inputIntensity = self.inputAmount;
    
    CIFilter *blendWithMaskFilter = [CIFilter filterWithName:@"CIBlendWithMask"];
    [blendWithMaskFilter setValue:self.inputImage forKey:kCIInputImageKey];
    [blendWithMaskFilter setValue:skinToneCurveFilter.outputImage forKey:kCIInputBackgroundImageKey];
    [blendWithMaskFilter setValue:rangeSelectionFilter.outputImage forKey:kCIInputMaskImageKey];
    
    CIFilter *shapenFilter = [CIFilter filterWithName:@"CISharpenLuminance"];
    [shapenFilter setValue:@(0.6 * self.inputAmount.floatValue) forKey:@"inputSharpness"];
    [shapenFilter setValue:blendWithMaskFilter.outputImage forKey:kCIInputImageKey];
    return shapenFilter.outputImage;
}

@end
