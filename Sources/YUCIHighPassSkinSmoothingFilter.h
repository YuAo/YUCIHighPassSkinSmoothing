//
//  YUCoreImageSkinEnhancementFilter.h
//  CoreImageSkinEnhancementFilter
//
//  Created by YuAo on 1/19/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface YUCIHighPassSkinSmoothingFilter : CIFilter

@property (nonatomic,retain) CIImage *inputImage;

@property (nonatomic,copy) NSNumber *inputAmount;

@end
