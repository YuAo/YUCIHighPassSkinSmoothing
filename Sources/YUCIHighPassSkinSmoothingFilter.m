//
//  YUCoreImageSkinEnhancementFilter.m
//  CoreImageSkinEnhancementFilter
//
//  Created by YuAo on 1/19/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

#import "YUCIHighPassSkinSmoothingFilter.h"
#import "YUCIColorLookupFilter.h"
#import "YUCIRGBToneCurveFilter.h"

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

@interface YUCIDermabrasionGaussianHighPassWithHardLightFilter : CIFilter

@property (nonatomic,strong) CIImage *inputImage;
@property (nonatomic,strong) CIImage *inputGaussianBlurredImage;

@end

@implementation YUCIDermabrasionGaussianHighPassWithHardLightFilter

+ (CIColorKernel *)filterKernel {
    static CIColorKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIDermabrasionGaussianHighPassWithHardLightFilter class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIColorKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (CIImage *)outputImage {
    return [[YUCIDermabrasionGaussianHighPassWithHardLightFilter filterKernel] applyWithExtent:self.inputImage.extent arguments:@[self.inputImage,self.inputGaussianBlurredImage]];
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
    
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setValue:self.inputRadius forKey:kCIInputRadiusKey];
    [blurFilter setValue:channelOverlayFilter.outputImage forKey:kCIInputImageKey];
    
    YUCIDermabrasionGaussianHighPassWithHardLightFilter *highpassWithHardLightFilter = [[YUCIDermabrasionGaussianHighPassWithHardLightFilter alloc] init];
    highpassWithHardLightFilter.inputImage = channelOverlayFilter.outputImage;
    highpassWithHardLightFilter.inputGaussianBlurredImage = blurFilter.outputImage;
    
    return highpassWithHardLightFilter.outputImage;
}

@end

#pragma mark - YUCISkinEnhancementFilter

@interface YUCIHighPassSkinSmoothingFilter ()

@property (nonatomic,strong) YUCIRGBToneCurveFilter *skinToneCurveFilter;

@end

@implementation YUCIHighPassSkinSmoothingFilter

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
    rangeSelectionFilter.inputRadius = self.inputRadius ?: @(8.0);
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
