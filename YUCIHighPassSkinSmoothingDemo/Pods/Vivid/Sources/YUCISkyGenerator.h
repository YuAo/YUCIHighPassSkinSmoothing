//
//  YUCISkyGenerator.h
//  Pods
//
//  Created by YuAo on 3/15/16.
//
//

#import <CoreImage/CoreImage.h>

@interface YUCISkyGenerator : CIFilter

@property (nonatomic, copy, null_resettable) CIVector *inputExtent;

@property (nonatomic, copy, null_resettable) CIVector *inputSunPosition;

@property (nonatomic, copy, null_resettable) NSNumber *inputSunIntensity;

@property (nonatomic, copy, null_resettable) CIVector *inputViewPointOffset;

@end
