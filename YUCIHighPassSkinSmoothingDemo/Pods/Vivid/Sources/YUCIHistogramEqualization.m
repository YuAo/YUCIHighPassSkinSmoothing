//
//  YUCIHistogramEqualization.m
//  Pods
//
//  Created by YuAo on 2/15/16.
//
//

#import "YUCIHistogramEqualization.h"
#import "YUCIFilterConstructor.h"
#import <Accelerate/Accelerate.h>

@interface YUCIHistogramEqualization ()

@property (nonatomic, strong) CIContext *context;

@end

@implementation YUCIHistogramEqualization

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:NSStringFromClass([YUCIHistogramEqualization class])
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo,kCICategoryColorAdjustment],
                                               kCIAttributeFilterDisplayName: @"Histogram Equalization"}];
            }
        }
    });
}

- (CIContext *)context {
    if (!_context) {
        _context = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace: CFBridgingRelease(CGColorSpaceCreateWithName(kCGColorSpaceSRGB))}];
    }
    return _context;
}

- (CIImage *)outputImage {
    if (!self.inputImage) {
        return nil;
    }
    
    ptrdiff_t rowBytes = self.inputImage.extent.size.width * 4; // ARGB has 4 components
    uint8_t *byteBuffer = calloc(rowBytes * self.inputImage.extent.size.height, sizeof(uint8_t)); // Buffer to render into
    [self.context render:self.inputImage
                toBitmap:byteBuffer
                rowBytes:rowBytes
                  bounds:self.inputImage.extent
                  format:kCIFormatARGB8
              colorSpace:self.context.workingColorSpace];
    
    vImage_Buffer vImageBuffer;
    vImageBuffer.data = byteBuffer;
    vImageBuffer.width = self.inputImage.extent.size.width;
    vImageBuffer.height = self.inputImage.extent.size.height;
    vImageBuffer.rowBytes = rowBytes;
    
    vImageEqualization_ARGB8888(&vImageBuffer, &vImageBuffer, kvImageNoFlags);
    
    NSData *bitmapData = [NSData dataWithBytesNoCopy:vImageBuffer.data length:vImageBuffer.rowBytes * vImageBuffer.height freeWhenDone:YES];
    CIImage *result = [[CIImage alloc] initWithBitmapData:bitmapData bytesPerRow:vImageBuffer.rowBytes size:CGSizeMake(vImageBuffer.width, vImageBuffer.height) format:kCIFormatARGB8 colorSpace:self.context.workingColorSpace];
    return result;
}

@end
