//
//  YUCIHighPassFilter.h
//  Pods
//
//  Created by YuAo on 1/22/16.
//
//

#import <CoreImage/CoreImage.h>

FOUNDATION_EXPORT NSString * const YUCIHighPass;

@interface YUCIHighPassFilter : CIFilter

@property (nonatomic,strong) CIImage *inputImage;

@property (nonatomic,copy) NSNumber *inputRadius; //default 1.0

@end
