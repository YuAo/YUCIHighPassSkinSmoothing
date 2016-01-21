//
//  YUCoreImageSkinEnhancementFilter.h
//  CoreImageSkinEnhancementFilter
//
//  Created by YuAo on 1/19/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface YUCIHighPassSkinSmoothingFilter : CIFilter

@property (nonatomic,strong) CIImage *inputImage;

@property (nonatomic,copy) NSNumber *inputAmount; //default: 1.0

@property (nonatomic,copy) NSNumber *inputRadius; //default: 8.0

@property (nonatomic,copy) NSArray<CIVector *> *inputToneCurveControlPoints; //default: (0,0) (120/255.0,146/255.0) (1,1)

@end
