//
//  YUCIUtilities.h
//  Pods
//
//  Created by YuAo on 2/17/16.
//
//

#import <Foundation/Foundation.h>

#define YUCI_METAMACRO_CONCAT(A, B) \
YUCI_METAMACRO_CONCAT_(A, B)

#define YUCI_METAMACRO_CONCAT_(A, B) A ## B

#define YUCIDefer \
    try {} @finally {} \
    __strong YUCIDeferCleanupBlock YUCI_METAMACRO_CONCAT(YUCIDeferBlock_, __LINE__) __attribute__((cleanup(YUCIDeferExecuteCleanupBlock), unused)) = ^

typedef void (^YUCIDeferCleanupBlock)();

void YUCIDeferExecuteCleanupBlock (__strong YUCIDeferCleanupBlock *block);
