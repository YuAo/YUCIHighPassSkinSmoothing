//
//  YUCIBilateralFilter.h
//  Pods
//
//  Created by YuAo on 2/2/16.
//
//

#import <CoreImage/CoreImage.h>

@interface YUCIBilateralFilter : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputImage;

@property (nonatomic, copy, null_resettable) NSNumber *inputRadius; //default 10
@property (nonatomic, copy, null_resettable) NSNumber *inputDistanceNormalizationFactor; //default 6.0
@property (nonatomic, copy, null_resettable) NSNumber *inputTexelSpacingMultiplier; //default 1.0

@end
