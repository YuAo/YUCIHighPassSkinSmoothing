//
//  YUCIReflectedTileROICalculator.h
//  Pods
//
//  Created by YuAo on 2/19/16.
//
//

#import <Foundation/Foundation.h>
#import "YUCIReflectedTile.h"

@interface YUCIReflectedTileROICalculator : NSObject

+ (CGRect)ROIForDestinationRect:(CGRect)destRect inputImageExtent:(CGRect)inputExtent mode:(YUCIReflectedTileMode)mode;

@end
