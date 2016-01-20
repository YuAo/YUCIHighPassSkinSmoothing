//
//  YUCIColorLookupFilter.h
//  CoreImageSkinEnhancementFilter
//
//  Created by YuAo on 1/20/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface YUCIColorLookupFilter : CIFilter

@property (nonatomic,retain) CIImage *inputImage;

@property (nonatomic,retain) CIImage *inputColorLookupTable;

@property (nonatomic,copy) NSNumber *inputIntensity;

@end
