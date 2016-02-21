//
//  YUCICLAHE.h
//  Pods
//
//  Created by YuAo on 2/16/16.
//
//

#import <CoreImage/CoreImage.h>

@interface YUCICLAHE : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputImage;

@property (nonatomic, copy, null_resettable) NSNumber *inputClipLimit; //default 1.0;

@property (nonatomic, copy, null_resettable) CIVector *inputTileGridSize; //default (x:8 y:8)

@end
