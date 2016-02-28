//
//  YUCoreImageSkinEnhancementFilter.h
//  CoreImageSkinEnhancementFilter
//
//  Created by YuAo on 1/19/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

#import <CoreImage/CoreImage.h>

/**
 YUCIHighPassSkinSmoothing is a subclass of CIFilter. It produces an output CIImage by performing a High Pass Skin Smoothing on the input image. https://github.com/YuAo/YUCIHighPassSkinSmoothing
 */

@interface YUCIHighPassSkinSmoothing : CIFilter

/**
 The input image.
 */
@property (nonatomic, strong, nullable) CIImage *inputImage;

/**
 A number value that controls the intensity of the `Curve Adjustment` step and the sharpness of the final `Sharpen` step. You use this value to control the overall filter strength. Valid from 0 to 1.0. The default value is 0.75.
 */
@property (nonatomic, copy, null_resettable) NSNumber *inputAmount;

/**
 A number value that controls the radius (in pixel) of the `High Pass` filter. The default value of this parameter is 8.0. Try adjusting this value according to the resolution of the input image and the level of detail you want to preserve.
 */
@property (nonatomic, copy, null_resettable) NSNumber *inputRadius;

/**
 A array of `CIVector` that defines the control points of the curve in `Curve Adjustment` step. The default value of this parameter is [(0,0), (120/255.0,146/255.0), (1,1)].
 */
@property (nonatomic, copy, null_resettable) NSArray<CIVector *> *inputToneCurveControlPoints;

/**
 A number value that controls the sharpness factor of the final `Sharpen` step. The sharpness value is calculated as `inputAmount * inputSharpnessFactor`. The default value for this parameter is 0.6.
 */
@property (nonatomic, copy, null_resettable) NSNumber *inputSharpnessFactor;

@end
