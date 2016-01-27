//
//  YUCIHighPassFilter.h
//  Pods
//
//  Created by YuAo on 1/22/16.
//
//

#import <CoreImage/CoreImage.h>

@interface YUCIHighPass : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputImage;

@property (nonatomic, copy, null_resettable) NSNumber *inputRadius; //default 1.0

@end
