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

@interface YUCIMetalUtilities : NSObject

+ (id<MTLTexture>)textureFormCGImage:(CGImageRef)imageRef device:(id<MTLDevice>)device;

@end

#endif
