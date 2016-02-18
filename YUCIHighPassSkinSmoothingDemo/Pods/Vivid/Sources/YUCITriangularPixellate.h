//
//  YUCITriangularPixellate.h
//  Pods
//
//  Created by YuAo on 2/9/16.
//
//

#import <CoreImage/CoreImage.h>

@interface YUCITriangularPixellate : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputImage;

@property (nonatomic, copy, null_resettable) NSNumber *inputVertexAngle; //default: M_PI/2.0

@property (nonatomic, copy, null_resettable) NSNumber *inputScale; //default: 20.0

@property (nonatomic, copy, null_resettable) CIVector *inputCenter; //default: (0,0)

@end
