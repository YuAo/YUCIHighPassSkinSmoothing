//
//  YUCIColorLookupFilter.h
//  CoreImageSkinEnhancementFilter
//
//  Created by YuAo on 1/20/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

#import <CoreImage/CoreImage.h>

/* 
 Note:
 
 1. Won't work with Metal backed CIContext. See YUCIColorLookupFilter.cikernel for detail.
 
 2. Requires CIContext object with a sRGB working color space instead of the default light-linear color space.
 
 */

@interface YUCIColorLookupFilter : CIFilter

@property (nonatomic,strong) CIImage *inputImage;

@property (nonatomic,strong) CIImage *inputColorLookupTable;

@property (nonatomic,copy) NSNumber *inputIntensity;

@end
