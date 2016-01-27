//
//  YUCIRGBToneCurveFilter.h
//  Pods
//
//  Created by YuAo on 1/21/16.
//
//

#import <CoreImage/CoreImage.h>

@interface YUCIRGBToneCurve : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputImage;

@property (nonatomic, copy, null_resettable) NSArray<CIVector *> *inputRedControlPoints;
@property (nonatomic, copy, null_resettable) NSArray<CIVector *> *inputGreenControlPoints;
@property (nonatomic, copy, null_resettable) NSArray<CIVector *> *inputBlueControlPoints;
@property (nonatomic, copy, null_resettable) NSArray<CIVector *> *inputRGBCompositeControlPoints;

@property (nonatomic, copy, null_resettable) NSNumber *inputIntensity; //default 1.0

@end
