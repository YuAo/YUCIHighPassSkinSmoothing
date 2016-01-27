//
//  YUCoreImageSkinEnhancementFilter.m
//  CoreImageSkinEnhancementFilter
//
//  Created by YuAo on 1/19/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

#import "YUCIHighPassSkinSmoothing.h"
#import "YUCIRGBToneCurve.h"
#import "YUCIHighPass.h"
#import "YUCIFilterConstructor.h"

#pragma mark - YUCIGreenBlueChannelOverlayBlend

@interface YUCIGreenBlueChannelOverlayBlend : CIFilter

@property (nonatomic,strong) CIImage *inputImage;

@end

@implementation YUCIGreenBlueChannelOverlayBlend

+ (CIColorKernel *)filterKernel {
    static CIColorKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIGreenBlueChannelOverlayBlend class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIColorKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (CIImage *)outputImage {
    return [[YUCIGreenBlueChannelOverlayBlend filterKernel] applyWithExtent:self.inputImage.extent arguments:@[self.inputImage]];
}

@end

#pragma mark - YUCIHighPassSkinSmoothingMaskHardLightBlend

@interface YUCIHighPassSkinSmoothingMaskBoost : CIFilter

@property (nonatomic,strong) CIImage *inputImage;

@end

@implementation YUCIHighPassSkinSmoothingMaskBoost

+ (CIColorKernel *)filterKernel {
    static CIColorKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIHighPassSkinSmoothingMaskBoost class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIColorKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (CIImage *)outputImage {
    return [[YUCIHighPassSkinSmoothingMaskBoost filterKernel] applyWithExtent:self.inputImage.extent arguments:@[self.inputImage]];
}

@end

#pragma mark - YUCIHighpassDermabrasionRangeSelectionFilter

@interface YUCIHighPassSkinSmoothingMaskGenerator: CIFilter

@property (nonatomic,strong) CIImage *inputImage;

@property (nonatomic,copy) NSNumber *inputRadius;

@end

@implementation YUCIHighPassSkinSmoothingMaskGenerator

- (CIImage *)outputImage {
    CIFilter *exposureFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
    [exposureFilter setValue:self.inputImage forKey:kCIInputImageKey];
    [exposureFilter setValue:@(-1.0) forKey:kCIInputEVKey];
    
    YUCIGreenBlueChannelOverlayBlend *channelOverlayFilter = [[YUCIGreenBlueChannelOverlayBlend alloc] init];
    channelOverlayFilter.inputImage = exposureFilter.outputImage;
    
    YUCIHighPass *highPassFilter = [[YUCIHighPass alloc] init];
    highPassFilter.inputImage = channelOverlayFilter.outputImage;
    highPassFilter.inputRadius = self.inputRadius;
    
    YUCIHighPassSkinSmoothingMaskBoost *hardLightFilter = [[YUCIHighPassSkinSmoothingMaskBoost alloc] init];
    hardLightFilter.inputImage = highPassFilter.outputImage;
    return hardLightFilter.outputImage;
}

@end

#pragma mark - YUCISkinEnhancementFilter

@interface YUCIHighPassSkinSmoothing ()

@property (nonatomic,strong) YUCIRGBToneCurve *skinToneCurveFilter;

@end

@implementation YUCIHighPassSkinSmoothing

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:NSStringFromClass([YUCIHighPassSkinSmoothing class])
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

- (YUCIRGBToneCurve *)skinToneCurveFilter {
    if (!_skinToneCurveFilter) {
        _skinToneCurveFilter = [[YUCIRGBToneCurve alloc] init];
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

- (void)setDefaults {
    self.inputAmount = nil;
    self.inputRadius = nil;
    self.skinToneCurveFilter = nil;
}

- (CIImage *)outputImage {
    YUCIHighPassSkinSmoothingMaskGenerator *maskGenerator = [[YUCIHighPassSkinSmoothingMaskGenerator alloc] init];
    maskGenerator.inputRadius = self.inputRadius;
    maskGenerator.inputImage = self.inputImage;
    
    YUCIRGBToneCurve *skinToneCurveFilter = self.skinToneCurveFilter;
    skinToneCurveFilter.inputImage = self.inputImage;
    skinToneCurveFilter.inputIntensity = self.inputAmount;
    
    CIFilter *blendWithMaskFilter = [CIFilter filterWithName:@"CIBlendWithMask"];
    [blendWithMaskFilter setValue:self.inputImage forKey:kCIInputImageKey];
    [blendWithMaskFilter setValue:skinToneCurveFilter.outputImage forKey:kCIInputBackgroundImageKey];
    [blendWithMaskFilter setValue:maskGenerator.outputImage forKey:kCIInputMaskImageKey];
    
    CIFilter *shapenFilter = [CIFilter filterWithName:@"CISharpenLuminance"];
    [shapenFilter setValue:@(0.6 * self.inputAmount.floatValue) forKey:@"inputSharpness"];
    [shapenFilter setValue:blendWithMaskFilter.outputImage forKey:kCIInputImageKey];
    return shapenFilter.outputImage;
}

@end
