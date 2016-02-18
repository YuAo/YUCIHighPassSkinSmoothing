//
//  YUCICrossZoomTransition.h
//  Pods
//
//  Created by YuAo on 2/4/16.
//
//

#import <CoreImage/CoreImage.h>

@interface YUCICrossZoomTransition : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputImage;
@property (nonatomic, strong, nullable) CIImage *inputTargetImage;

@property (nonatomic, copy, nullable) CIVector *inputExtent;

@property (nonatomic, copy, null_resettable) NSNumber *inputStrength; //default 0.3

@property (nonatomic, copy, null_resettable) NSNumber *inputTime; /* 0 to 1 */

@end
