//
//  YUCIReflectedTileROICalculator.m
//  Pods
//
//  Created by YuAo on 2/19/16.
//
//

#import "YUCIReflectedTileROICalculator.h"

static void YUCIReflectedTileROICalculatorSplitRectWithBorderOfRect(CGRect rect,
                                                                    CGRect split,
                                                                    CGRect *insider,
                                                                    CGRect *verticalRemining,
                                                                    CGRect *horizonalRemining,
                                                                    CGRect *diagonalRemining)
{
    CGRect insideRect = CGRectIntersection(split, rect);
    
    CGRect unused;
    CGRect verticalRect;
    CGRectDivide(rect, &unused, &verticalRect, insideRect.size.height, CGRectMinYEdge);
    CGRect horizonalRect;
    CGRectDivide(rect, &unused, &horizonalRect, insideRect.size.width, CGRectMinXEdge);
    CGRect diagonalRect = CGRectIntersection(verticalRect, horizonalRect);
    verticalRect.size.width -= diagonalRect.size.width;
    horizonalRect.size.height -= diagonalRect.size.height;
    
    *insider = insideRect;
    *verticalRemining = verticalRect;
    *horizonalRemining = horizonalRect;
    *diagonalRemining = diagonalRect;
}

@implementation YUCIReflectedTileROICalculator

+ (NSArray *)map:(NSArray *)array usingBlock:(id (^)(id))mapper {
    NSMutableArray *result = [NSMutableArray new];
    for (id element in array) {
        [result addObject:mapper(element)];
    }
    return result.copy;
}

+ (id)reduce:(NSArray *)array seed:(id)seed combiner:(id (^)(id, id))combiner {
    id current = seed;
    for (id element in array) {
        current = combiner(current, element);
    }
    return current;
}

+ (NSArray *)filter:(NSArray *)array usingFilter:(BOOL (^)(id))filter {
    NSMutableArray *filteredArray = [NSMutableArray array];
    for (id element in array) {
        if (filter(element)) {
            [filteredArray addObject:element];
        }
    }
    return filteredArray.copy;
}

+ (CGPoint)locationForPoint:(CGPoint)point inOrigin4GridRect:(CGRect)origin4GridRect {
    CGPoint result = CGPointZero;
    result.x = ((NSInteger)(point.x - origin4GridRect.origin.x) % (NSInteger)origin4GridRect.size.width);
    result.y = ((NSInteger)(point.y - origin4GridRect.origin.y) % (NSInteger)origin4GridRect.size.height);
    return result;
}

+ (CGRect)rectByHorizonallyFoldingRect:(CGRect)rect insideRect:(CGRect)boundingRect {
    CGFloat distance = rect.origin.x - (boundingRect.origin.x + boundingRect.size.width);
    if (distance >= 0) {
        CGRect result = rect;
        result.origin.x = boundingRect.size.width - distance - result.size.width + boundingRect.origin.x;
        return result;
    } else {
        CGRect inside, vertical, horizonal, diagonal;
        YUCIReflectedTileROICalculatorSplitRectWithBorderOfRect(rect, boundingRect, &inside, &vertical, &horizonal, &diagonal);
        if (CGRectIsEmpty(horizonal)) {
            return inside;
        }
        horizonal.origin.x = horizonal.origin.x - horizonal.size.width;
        return CGRectUnion(inside, horizonal);
    }
}

+ (CGRect)rectByVerticallyFoldingRect:(CGRect)rect insideRect:(CGRect)boundingRect {
    CGFloat distance = rect.origin.y - (boundingRect.origin.y + boundingRect.size.height);
    if (distance >= 0) {
        CGRect result = rect;
        result.origin.y = boundingRect.size.height - distance - result.size.height + boundingRect.origin.y;
        return result;
    } else {
        CGRect inside, vertical, horizonal, diagonal;
        YUCIReflectedTileROICalculatorSplitRectWithBorderOfRect(rect, boundingRect, &inside, &vertical, &horizonal, &diagonal);
        if (CGRectIsEmpty(vertical)) {
            return inside;
        }
        vertical.origin.y = vertical.origin.y - horizonal.size.height;
        return CGRectUnion(inside, vertical);
    }
}

+ (CGRect)ROIForDestinationRect:(CGRect)destRect inputImageExtent:(CGRect)inputExtent mode:(YUCIReflectedTileMode)mode {
    if (CGRectContainsRect(inputExtent, destRect)) {
        return destRect;
    } else if(CGRectContainsRect(destRect, inputExtent)) {
        return inputExtent;
    }
    
    CGFloat modeDiff = (mode == YUCIReflectedTileModeReflectWithoutBorder ? 1 : 0);
    CGRect grid = CGRectMake(inputExtent.origin.x, inputExtent.origin.y, inputExtent.size.width * 2 - modeDiff, inputExtent.size.height * 2 - modeDiff);
    
    destRect.origin = [self locationForPoint:destRect.origin inOrigin4GridRect:grid];
    
    CGRect inside, vertical, horizonal, diagonal;
    YUCIReflectedTileROICalculatorSplitRectWithBorderOfRect(destRect, grid, &inside, &vertical, &horizonal, &diagonal);
    if (CGRectIsEmpty(inside)) {
        return CGRectZero;
    }
    
    //align rects
    vertical.origin.y -= grid.size.height;
    horizonal.origin.x -= grid.size.width;
    diagonal.origin.y -= grid.size.height;
    diagonal.origin.x -= grid.size.width;
    
    vertical = CGRectIntersection(grid, vertical);
    horizonal = CGRectIntersection(grid, horizonal);
    diagonal = CGRectIntersection(grid, diagonal);
    
    NSArray *rects = ({
        NSMutableArray *rectsM = [NSMutableArray array];
        [rectsM addObject:[CIVector vectorWithCGRect:inside]];
        [rectsM addObject:[CIVector vectorWithCGRect:vertical]];
        [rectsM addObject:[CIVector vectorWithCGRect:horizonal]];
        [rectsM addObject:[CIVector vectorWithCGRect:diagonal]];
        rectsM.copy;
    });
    
    rects = [self filter:rects usingFilter:^BOOL(CIVector *rectValue) {
        if (CGRectIsEmpty(rectValue.CGRectValue)) {
            return NO;
        }
        return YES;
    }];
    
    rects = [self map:rects usingBlock:^id(CIVector *rectValue) {
        CGRect rect = [rectValue CGRectValue];
        rect = [self rectByHorizonallyFoldingRect:rect insideRect:CGRectMake(inputExtent.origin.x, inputExtent.origin.y, inputExtent.size.width, grid.size.height)];
        rect = [self rectByVerticallyFoldingRect:rect insideRect:inputExtent];
        rect = CGRectInset(rect, -1, -1);
        return [CIVector vectorWithCGRect:rect];
    }];
    
    CIVector *result = [self reduce:rects seed:nil combiner:^id(CIVector *pre, CIVector *current) {
        if (pre) {
            return [CIVector vectorWithCGRect:CGRectUnion(pre.CGRectValue, current.CGRectValue)];
        }
        return current;
    }];
    
    CGRect ROI = CGRectIntersection(inputExtent, result.CGRectValue);
    return ROI;
}

@end
