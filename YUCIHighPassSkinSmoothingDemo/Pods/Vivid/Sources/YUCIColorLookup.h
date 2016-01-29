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

 Requires CIContext object with a sRGB working color space instead of the default light-linear color space.
 
 */

@interface YUCIColorLookup : CIFilter

@property (nonatomic,strong) CIImage *inputImage;

@property (nonatomic,strong) CIImage *inputColorLookupTable;

@property (nonatomic,copy) NSNumber *inputIntensity;

@end
