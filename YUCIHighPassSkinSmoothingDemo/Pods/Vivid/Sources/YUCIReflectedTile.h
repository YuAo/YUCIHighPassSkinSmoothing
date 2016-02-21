//
//  YUCIReflectTile.h
//  Pods
//
//  Created by YuAo on 2/16/16.
//
//

#import <CoreImage/CoreImage.h>

typedef NS_ENUM(NSInteger, YUCIReflectedTileMode) {
    YUCIReflectedTileModeReflectWithoutBorder = 0,
    YUCIReflectedTileModeReflectWithBorder = 1,
};

@interface YUCIReflectedTile : CIFilter

@property (nonatomic, strong, nullable) CIImage *inputImage;

@property (nonatomic, copy, null_resettable) NSNumber *inputMode; //default: YUCIReflectedTileModeReflectWithoutBorder

@end
