//
//  YUCIMetalUtilities.h
//  Pods
//
//  Created by YuAo on 1/20/16.
//
//
#if __has_include(<Metal/Metal.h>)

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface YUCIMetalUtilities : NSObject

+ (id<MTLTexture>)textureFromCGImage:(CGImageRef)imageRef device:(id<MTLDevice>)device;

@end

NS_ASSUME_NONNULL_END

#endif
