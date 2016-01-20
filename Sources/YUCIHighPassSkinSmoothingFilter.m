//
//  YUCoreImageSkinEnhancementFilter.m
//  CoreImageSkinEnhancementFilter
//
//  Created by YuAo on 1/19/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

#import "YUCIHighPassSkinSmoothingFilter.h"
#import "YUCIColorLookupFilter.h"

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

@end

@implementation YUCIHighPassDermabrasionRangeSelectionFilter

- (CIImage *)outputImage {
    CIFilter *exposureFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
    [exposureFilter setValue:self.inputImage forKey:kCIInputImageKey];
    [exposureFilter setValue:@(-1.0) forKey:kCIInputEVKey];
    
    YUCIGreenBlueChannelOverlayBlendFilter *channelOverlayFilter = [[YUCIGreenBlueChannelOverlayBlendFilter alloc] init];
    channelOverlayFilter.inputImage = exposureFilter.outputImage;
    
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setValue:@(8.0 * self.inputImage.extent.size.width/750.0) forKey:kCIInputRadiusKey];
    [blurFilter setValue:channelOverlayFilter.outputImage forKey:kCIInputImageKey];
    
    YUCIDermabrasionGaussianHighPassWithHardLightFilter *highpassWithHardLightFilter = [[YUCIDermabrasionGaussianHighPassWithHardLightFilter alloc] init];
    highpassWithHardLightFilter.inputImage = channelOverlayFilter.outputImage;
    highpassWithHardLightFilter.inputGaussianBlurredImage = blurFilter.outputImage;
    
    return highpassWithHardLightFilter.outputImage;
}

@end

#pragma mark - YUCIHighpassDermabrasionComposeFilter

@interface YUCIHighPassDermabrasionComposeFilter : CIFilter

@property (nonatomic,strong) CIImage *inputImage;
@property (nonatomic,strong) CIImage *inputMaskImage;
@property (nonatomic,strong) CIImage *inputRefinedImage;

@end

@implementation YUCIHighPassDermabrasionComposeFilter

+ (CIColorKernel *)filterKernel {
    static CIColorKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIHighPassDermabrasionComposeFilter class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIColorKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (CIImage *)outputImage {
    return [[YUCIHighPassDermabrasionComposeFilter filterKernel] applyWithExtent:self.inputImage.extent arguments:@[self.inputImage,self.inputRefinedImage,self.inputMaskImage]];
}

@end

#pragma mark - YUCISkinEnhancementFilter

@interface YUCIHighPassSkinSmoothingFilter ()

@property (nonatomic,strong) YUCIColorLookupFilter *skinColorLookupFilter;

@end

@implementation YUCIHighPassSkinSmoothingFilter

- (YUCIColorLookupFilter *)skinColorLookupFilter {
    if (!_skinColorLookupFilter) {
        _skinColorLookupFilter = [[YUCIColorLookupFilter alloc] init];
        _skinColorLookupFilter.inputColorLookupTable = [CIImage imageWithContentsOfURL:[[NSBundle bundleForClass:self.class] URLForResource:@"YUCISkinRefineLUT" withExtension:@"png"]];
    }
    return _skinColorLookupFilter;
}

- (CIImage *)outputImage {
    YUCIHighPassDermabrasionRangeSelectionFilter *rangeSelectionFilter = [[YUCIHighPassDermabrasionRangeSelectionFilter alloc] init];
    rangeSelectionFilter.inputImage = self.inputImage;
    
    YUCIColorLookupFilter *skinColorLookupFilter = self.skinColorLookupFilter;
    skinColorLookupFilter.inputImage = self.inputImage;
    skinColorLookupFilter.inputIntensity = self.inputAmount;
    
    YUCIHighPassDermabrasionComposeFilter *composeFilter = [[YUCIHighPassDermabrasionComposeFilter alloc] init];
    composeFilter.inputImage = self.inputImage;
    composeFilter.inputMaskImage = rangeSelectionFilter.outputImage;
    composeFilter.inputRefinedImage = skinColorLookupFilter.outputImage;
    
    CIFilter *shapenFilter = [CIFilter filterWithName:@"CISharpenLuminance"];
    [shapenFilter setValue:@(0.5 * self.inputAmount.floatValue) forKey:@"inputSharpness"];
    
    return composeFilter.outputImage;
}

@end
