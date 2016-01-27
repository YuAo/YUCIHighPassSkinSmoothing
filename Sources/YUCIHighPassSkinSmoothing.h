//
//  YUCoreImageSkinEnhancementFilter.h
//  CoreImageSkinEnhancementFilter
//
//  Created by YuAo on 1/19/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface YUCIHighPassSkinSmoothing : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputImage;

@property (nonatomic, copy, null_resettable) NSNumber *inputAmount; //default: 0.75

@property (nonatomic, copy, null_resettable) NSNumber *inputRadius; //default: 8.0

@property (nonatomic, copy, null_resettable) NSArray<CIVector *> *inputToneCurveControlPoints; //default: (0,0) (120/255.0,146/255.0) (1,1)

@end
