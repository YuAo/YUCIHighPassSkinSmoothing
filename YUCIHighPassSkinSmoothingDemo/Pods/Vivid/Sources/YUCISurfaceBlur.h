//
//  YUCISurfaceBlur.h
//  Pods
//
//  Created by YuAo on 2/3/16.
//
//

#import <CoreImage/CoreImage.h>

@interface YUCISurfaceBlur : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputImage;

@property (nonatomic, copy, null_resettable) NSNumber *inputRadius; //default 10

@property (nonatomic, copy, null_resettable) NSNumber *inputThreshold; //0.0-255.0; //default 10

@end
