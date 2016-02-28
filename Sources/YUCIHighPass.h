//
//  YUCIHighPassFilter.h
//  Pods
//
//  Created by YuAo on 1/22/16.
//
//

#import <CoreImage/CoreImage.h>

/**
 YUCIHighPass is a subclass of CIFilter. Its kernel can be represented with the following code:
 
 @code highpass.rgb = image.rgb - gaussianBlurredImage.rgb + vec3(0.5,0.5,0.5)
 */

@interface YUCIHighPass : CIFilter

/**
 The input image.
 */
@property (nonatomic, strong, nullable) CIImage *inputImage;

/**
 A number value that controls the radius (in pixel) of the filter. The default value of this parameter is 1.0.
 */
@property (nonatomic, copy, null_resettable) NSNumber *inputRadius;

@end
