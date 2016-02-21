//
//  YUCIFilterPreviewGenerator.m
//  Pods
//
//  Created by YuAo on 2/14/16.
//
//

#import "YUCIFilterPreviewGenerator.h"
#import <ImageIO/ImageIO.h>
#if __has_include(<MobileCoreServices/MobileCoreServices.h>)
    #import <MobileCoreServices/MobileCoreServices.h>
#endif

CGSize  const YUCIFilterPreviewImageSize = (CGSize){280,210};
CGFloat const YUCIFilterPreviewImageSpacing = 60;
CGFloat const YUCIFilterPreviewAreaEdgeInset = 0;

CGRect YUCIMakeRectWithAspectRatioFillRect(CGSize aspectRatio, CGRect boundingRect) {
    if (CGRectIsInfinite(boundingRect)) {
        boundingRect = CGRectMake(0, 0, 1600, 1200);
    }
    CGFloat horizontalRatio = boundingRect.size.width / aspectRatio.width;
    CGFloat verticalRatio = boundingRect.size.height / aspectRatio.height;
    CGFloat ratio;
    
    ratio = MAX(horizontalRatio, verticalRatio);
    //ratio = MIN(horizontalRatio, verticalRatio);
    
    CGSize newSize = CGSizeMake(floor(aspectRatio.width * ratio), floor(aspectRatio.height * ratio));
    CGRect rect = CGRectMake(boundingRect.origin.x + (boundingRect.size.width - newSize.width)/2, boundingRect.origin.y + (boundingRect.size.height - newSize.height)/2, newSize.width, newSize.height);
    return rect;
}

@implementation YUCIFilterPreviewGenerator

+ (void)generatePreviewForFilter:(CIFilter *)filter context:(CIContext *)inputContext completion:(void (^)(NSData *, NSString *))completion {
    
    CIContext *context = inputContext;
    if (!context) {
        context = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace: CFBridgingRelease(CGColorSpaceCreateWithName(kCGColorSpaceSRGB))}];
    }
    
    NSArray *categories = filter.attributes[kCIAttributeFilterCategories];
    if([categories containsObject:kCICategoryTransition]) {
        //transition
        NSData *data = [self generateGIFPreviewForFilter:filter context:context duration:2.0 frameCallback:^(NSTimeInterval frameTime) {
            [filter setValue:@(frameTime/2.0) forKey:@"inputTime"];
        }];
        completion(data,[filter.name stringByAppendingPathExtension:@"gif"]);
    } else if ([categories containsObject:kCICategoryGenerator] && [filter.inputKeys containsObject:@"inputTime"]) {
        //animatable generator
        NSData *data = [self generateGIFPreviewForFilter:filter context:context duration:5.0 frameCallback:^(NSTimeInterval frameTime) {
            [filter setValue:@(frameTime) forKey:@"inputTime"];
        }];
        completion(data,[filter.name stringByAppendingPathExtension:@"gif"]);
    } else {
        NSMutableArray *inputImageKeys = [NSMutableArray array];
        for (NSString *inputKey in filter.inputKeys) {
            id value = [filter valueForKey:inputKey];
            if ([value isKindOfClass:[CIImage class]]) {
                if ([inputKey isEqualToString:kCIInputImageKey]) {
                    [inputImageKeys insertObject:inputKey atIndex:0];
                } else {
                    [inputImageKeys addObject:inputKey];
                }
            }
        }
        NSMutableData *data = [NSMutableData data];
        CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)data, kUTTypePNG, 1, NULL);
        //NSDictionary *properties = @{(NSString *)kCGImageDestinationLossyCompressionQuality: @(0.75)};
        //CGImageDestinationSetProperties(destination,(CFDictionaryRef)properties);
        CGImageRef image = [self generatePreviewForFilter:filter context:context inputImageKeys:inputImageKeys];
        CGImageDestinationAddImage(destination, image, NULL);
        CGImageDestinationFinalize(destination);
        CFRelease(destination);
        completion(data,[filter.name stringByAppendingPathExtension:@"png"]);
    }
}

+ (NSData *)generateGIFPreviewForFilter:(CIFilter *)filter context:(CIContext *)context duration:(NSTimeInterval)duration frameCallback:(void (^)(NSTimeInterval frameTime))frameCallback {
    NSInteger framePerSecond = 30;
    NSMutableData *data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)data, kUTTypeGIF, (size_t)floor(framePerSecond * duration), NULL);
    for (NSInteger frame = 0; frame < framePerSecond * duration; ++frame) {
        frameCallback(frame/(double)framePerSecond);
        CGImageRef image = [self generatePreviewForFilter:filter context:context inputImageKeys:nil];
        NSDictionary *frameProperties = @{(NSString *)kCGImagePropertyGIFDictionary:
                                              @{(NSString *)kCGImagePropertyGIFDelayTime: @(1.0/framePerSecond)}
                                          };
        CGImageDestinationAddImage(destination, image, (CFDictionaryRef)frameProperties);
    }
    NSDictionary *gifProperties = @{(NSString *)kCGImagePropertyGIFDictionary:
                                        @{(NSString *)kCGImagePropertyGIFLoopCount: @(0)}
                                    };
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    return data.copy;
}

+ (void)drawPlusSignInRect:(CGRect)rect context:(CGContextRef)context {
    CGFloat size = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect));
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, center.x - size/2.0, center.y);
    CGPathAddLineToPoint(path, NULL, center.x + size/2.0, center.y);
    CGPathMoveToPoint(path, NULL, center.x, center.y - size/2.0);
    CGPathAddLineToPoint(path, NULL, center.x, center.y + size/2.0);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGPathRelease(path);
}

+ (void)drawArrowSignInRect:(CGRect)rect context:(CGContextRef)context {
    CGFloat size = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/2.0;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, center.x - size/2.0, center.y - size);
    CGPathAddLineToPoint(path, NULL, center.x + size/2.0, center.y);
    CGPathAddLineToPoint(path, NULL, center.x - size/2.0, center.y + size);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGPathRelease(path);
}

+ (CGImageRef)generatePreviewForFilter:(CIFilter *)filter context:(CIContext *)context inputImageKeys:(NSArray *)inputImageKeys {
    //filter
    NSMutableArray *inputImages = [NSMutableArray array];
    for (NSString *inputKey in inputImageKeys) {
        id value = [filter valueForKey:inputKey];
        if ([value isKindOfClass:[CIImage class]]) {
            [inputImages addObject:value];
        }
    }
    
    CGRect previewRect = CGRectMake(0, 0, (inputImages.count + 1) * YUCIFilterPreviewImageSize.width + inputImages.count * YUCIFilterPreviewImageSpacing + YUCIFilterPreviewAreaEdgeInset * 2.0, YUCIFilterPreviewImageSize.height + YUCIFilterPreviewAreaEdgeInset * 2.0);
    
    CGImageRef image = [self imageByPerformingDrawing:^(CGContextRef cgContext) {
        CGContextSetLineWidth(cgContext, 5);
        CGFloat color[4] = {0.7,0.7,0.7,1.0};
        CGContextSetStrokeColor(cgContext, color);
        CGContextSetLineJoin(cgContext, kCGLineJoinRound);
        
        CIImage *backgroundImage = [CIImage imageWithColor:[CIColor colorWithRed:0 green:0 blue:0 alpha:0.05]];
        CGFloat x = YUCIFilterPreviewAreaEdgeInset;
        for (CIImage *inputImage in inputImages) {
            CGImageRef inputCGImage = [context createCGImage:[inputImage imageByCompositingOverImage:backgroundImage] fromRect:YUCIMakeRectWithAspectRatioFillRect(YUCIFilterPreviewImageSize, inputImage.extent)];
            CGContextDrawImage(cgContext, (CGRect){{x,YUCIFilterPreviewAreaEdgeInset},YUCIFilterPreviewImageSize}, inputCGImage);
            CGImageRelease(inputCGImage);
            
            x += YUCIFilterPreviewImageSize.width;
            
            CGRect spacingRect = CGRectInset(CGRectMake(x, YUCIFilterPreviewAreaEdgeInset, YUCIFilterPreviewImageSpacing, YUCIFilterPreviewImageSize.height), 15, 15);
            if (inputImage == inputImages.lastObject) {
                //>
                [self drawArrowSignInRect:spacingRect context:cgContext];
            } else {
                //+
                [self drawPlusSignInRect:spacingRect context:cgContext];
            }
            
            x += YUCIFilterPreviewImageSpacing;
        }
        
        {
            //render output image
            CGImageRef inputCGImage = [context createCGImage:[filter.outputImage imageByCompositingOverImage:backgroundImage] fromRect:YUCIMakeRectWithAspectRatioFillRect(YUCIFilterPreviewImageSize, filter.outputImage.extent)];
            CGContextDrawImage(cgContext, (CGRect){{x,YUCIFilterPreviewAreaEdgeInset},YUCIFilterPreviewImageSize}, inputCGImage);
            CGImageRelease(inputCGImage);
        }
    } inRect:previewRect];
    
    return image;
}

+ (CGImageRef)imageByPerformingDrawing:(void (^)(CGContextRef context))drawing inRect:(CGRect)rect {
    // Build a context that's the same dimensions as the new size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                rect.size.width,
                                                rect.size.height,
                                                8,
                                                0,
                                                colorSpace,
                                                bitmapInfo);
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationMedium);
    
    drawing(bitmap);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    
    // Clean up
    CFAutorelease(newImageRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(bitmap);
    
    return newImageRef;
}

@end
