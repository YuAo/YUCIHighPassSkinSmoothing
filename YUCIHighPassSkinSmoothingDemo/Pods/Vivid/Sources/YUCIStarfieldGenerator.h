//
//  YUCIStarNestGenerator.h
//  Pods
//
//  Created by YuAo on 2/4/16.
//
//

#import <CoreImage/CoreImage.h>

@interface YUCIStarfieldGenerator : CIFilter

@property (nonatomic, copy, null_resettable) CIVector *inputExtent;

@property (nonatomic, copy, null_resettable) NSNumber *inputTime;

@property (nonatomic, copy, null_resettable) CIVector *inputRotation;

@end
