//
//  YUCIFilterPreviewGenerator.h
//  Pods
//
//  Created by YuAo on 2/14/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface YUCIFilterPreviewGenerator : NSObject

+ (void)generatePreviewForFilter:(CIFilter *)filter
                         context:(nullable CIContext *)context
                      completion:(void (^)(NSData *previewData, NSString *preferredFilename))completion;

@end

NS_ASSUME_NONNULL_END
