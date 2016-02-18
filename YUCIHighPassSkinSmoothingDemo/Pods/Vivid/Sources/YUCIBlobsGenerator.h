//
//  YUCIBlobsGenerator.h
//  Pods
//
//  Created by YuAo on 2/6/16.
//
//

#import <CoreImage/CoreImage.h>

@interface YUCIBlobsGenerator : CIFilter

@property (nonatomic, copy, null_resettable) CIVector *inputExtent; //default 640x800

@property (nonatomic, copy, null_resettable) NSNumber *inputTime; //default 0


@end
