//
//  YUCIUtilities.m
//  Pods
//
//  Created by YuAo on 2/17/16.
//
//

#import "YUCIUtilities.h"

void YUCIDeferExecuteCleanupBlock (__strong YUCIDeferCleanupBlock *block) {
    (*block)();
}
