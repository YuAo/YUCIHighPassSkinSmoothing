//
//  YUCIFilterUtilities.m
//  Pods
//
//  Created by YuAo on 2/3/16.
//
//

#import "YUCIFilterUtilities.h"

double YUCIGaussianDistributionPDF(double x, double sigma) {
    return 1.0/sqrt(2 * M_PI * sigma * sigma) * exp((- x * x) / (2 * sigma * sigma));
}