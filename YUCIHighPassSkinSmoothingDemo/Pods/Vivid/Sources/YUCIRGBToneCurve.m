//
//  YUCIRGBToneCurveFilter.m
//  Pods
//
//  Created by YuAo on 1/21/16.
//
//

#import "YUCIRGBToneCurve.h"
#import "YUCIFilterConstructor.h"

static NSCache * YUCIRGBToneCurveSplineCurveCache(void) {
    static NSCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
        cache.name = @"YUCIRGBToneCurveSplineCurveCache";
        cache.totalCostLimit = 40;
    });
    return cache;
}

@interface YUCIRGBToneCurve ()

@property (nonatomic,copy) NSArray<NSNumber *> *redCurve, *greenCurve, *blueCurve, *rgbCompositeCurve;

@property (nonatomic,strong) CIImage *toneCurveTexture;

@end

@implementation YUCIRGBToneCurve

@synthesize inputRGBCompositeControlPoints = _inputRGBCompositeControlPoints;
@synthesize inputRedControlPoints = _inputRedControlPoints;
@synthesize inputGreenControlPoints = _inputGreenControlPoints;
@synthesize inputBlueControlPoints = _inputBlueControlPoints;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if ([CIFilter respondsToSelector:@selector(registerFilterName:constructor:classAttributes:)]) {
                [CIFilter registerFilterName:NSStringFromClass([YUCIRGBToneCurve class])
                                 constructor:[YUCIFilterConstructor constructor]
                             classAttributes:@{kCIAttributeFilterCategories: @[kCICategoryStillImage,kCICategoryVideo, kCICategoryColorAdjustment,kCICategoryInterlaced],
                                               kCIAttributeFilterDisplayName: @"RGB Tone Curve"}];
            }
        }
    });
}

+ (CIKernel *)filterKernel {
    static CIKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *kernelString = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:self] URLForResource:NSStringFromClass([YUCIRGBToneCurve class]) withExtension:@"cikernel"] encoding:NSUTF8StringEncoding error:nil];
        kernel = [CIKernel kernelWithString:kernelString];
    });
    return kernel;
}

- (NSNumber *)inputIntensity {
    if (!_inputIntensity) {
        _inputIntensity = @(1.0);
    }
    return _inputIntensity;
}

- (NSArray<CIVector *> *)defaultCurveControlPoints {
    return @[[CIVector vectorWithX:0 Y:0],
             [CIVector vectorWithX:0.5 Y:0.5],
             [CIVector vectorWithX:1 Y:1]];
}

- (void)setDefaults {
    self.inputIntensity = nil;
    self.inputRedControlPoints = nil;
    self.inputGreenControlPoints = nil;
    self.inputBlueControlPoints = nil;
    self.inputRGBCompositeControlPoints = nil;
}

- (CIImage *)outputImage {
    if (!self.inputImage) {
        return nil;
    }
    
    if (!self.toneCurveTexture) {
        [self updateToneCurveTexture];
    }
    
    return [[YUCIRGBToneCurve filterKernel] applyWithExtent:self.inputImage.extent
                                                roiCallback:^CGRect(int index, CGRect destRect) {
                                                    if (index == 0) {
                                                        return destRect;
                                                    } else {
                                                        return self.toneCurveTexture.extent;
                                                    }
                                                }
                                                  arguments:@[self.inputImage,
                                                              self.toneCurveTexture,
                                                              self.inputIntensity]];
}

- (void)updateToneCurveTexture {
    if (self.rgbCompositeCurve.count != 256) {
        self.rgbCompositeCurve = [self getPreparedSplineCurve:self.inputRGBCompositeControlPoints];
    }
    
    if (self.redCurve.count != 256) {
        self.redCurve = [self getPreparedSplineCurve:self.inputRedControlPoints];
    }
    
    if (self.greenCurve.count != 256) {
        self.greenCurve = [self getPreparedSplineCurve:self.inputGreenControlPoints];
    }
    
    if (self.blueCurve.count != 256) {
        self.blueCurve = [self getPreparedSplineCurve:self.inputBlueControlPoints];
    }
    
    uint8_t *toneCurveByteArray = calloc(256 * 4, sizeof(uint8_t));
    for (NSUInteger currentCurveIndex = 0; currentCurveIndex < 256; currentCurveIndex++)
    {
        // BGRA for upload to texture
        uint8_t b = fmin(fmax(currentCurveIndex + self.blueCurve[currentCurveIndex].floatValue, 0), 255);
        toneCurveByteArray[currentCurveIndex * 4] = fmin(fmax(b + self.rgbCompositeCurve[b].floatValue, 0), 255);
        uint8_t g = fmin(fmax(currentCurveIndex + self.greenCurve[currentCurveIndex].floatValue, 0), 255);
        toneCurveByteArray[currentCurveIndex * 4 + 1] = fmin(fmax(g + self.rgbCompositeCurve[g].floatValue, 0), 255);
        uint8_t r = fmin(fmax(currentCurveIndex + self.redCurve[currentCurveIndex].floatValue, 0), 255);
        toneCurveByteArray[currentCurveIndex * 4 + 2] = fmin(fmax(r + self.rgbCompositeCurve[r].floatValue, 0), 255);
        toneCurveByteArray[currentCurveIndex * 4 + 3] = 255;
    }
    CIImage *toneCurveTexture = [CIImage imageWithBitmapData:[NSData dataWithBytesNoCopy:toneCurveByteArray length:256 * 4 * sizeof(uint8_t) freeWhenDone:YES] bytesPerRow:256 * 4 * sizeof(uint8_t) size:CGSizeMake(256, 1) format:kCIFormatBGRA8 colorSpace:nil];
    self.toneCurveTexture = toneCurveTexture;
}

- (NSArray<CIVector *> *)inputRGBCompositeControlPoints {
    if (_inputRGBCompositeControlPoints.count == 0) {
        _inputRGBCompositeControlPoints = self.defaultCurveControlPoints;
    }
    return _inputRGBCompositeControlPoints;
}

- (NSArray<CIVector *> *)inputRedControlPoints {
    if (_inputRedControlPoints.count == 0) {
        _inputRedControlPoints = self.defaultCurveControlPoints;
    }
    return _inputRedControlPoints;
}

- (NSArray<CIVector *> *)inputGreenControlPoints {
    if (_inputGreenControlPoints.count == 0) {
        _inputGreenControlPoints = self.defaultCurveControlPoints;
    }
    return _inputGreenControlPoints;
}

- (NSArray<CIVector *> *)inputBlueControlPoints {
    if (_inputBlueControlPoints.count == 0) {
        _inputBlueControlPoints = self.defaultCurveControlPoints;
    }
    return _inputBlueControlPoints;
}

- (void)setInputRGBCompositeControlPoints:(NSArray<CIVector *> *)inputRGBCompositeControlPoints {
    _inputRGBCompositeControlPoints = inputRGBCompositeControlPoints.copy;
    _rgbCompositeCurve = nil;
    _toneCurveTexture = nil;
}

- (void)setInputRedControlPoints:(NSArray<CIVector *> *)inputRedControlPoints {
    _inputRedControlPoints = inputRedControlPoints.copy;
    _redCurve = nil;
    _toneCurveTexture = nil;
}

- (void)setInputGreenControlPoints:(NSArray<CIVector *> *)inputGreenControlPoints {
    _inputGreenControlPoints = inputGreenControlPoints.copy;
    _greenCurve = nil;
    _toneCurveTexture = nil;
}

- (void)setInputBlueControlPoints:(NSArray<CIVector *> *)inputBlueControlPoints {
    _inputBlueControlPoints = inputBlueControlPoints.copy;
    _blueCurve = nil;
    _toneCurveTexture = nil;
}

#pragma mark - Curve calculation

- (NSArray *)getPreparedSplineCurve:(NSArray *)points
{
    NSArray *cachedCurve = [YUCIRGBToneCurveSplineCurveCache() objectForKey:points];
    if (cachedCurve) {
        return cachedCurve;
    }
    
    if (points && [points count] > 0)
    {
        // Sort the array.
        NSArray *sortedPoints = [points sortedArrayUsingComparator:^NSComparisonResult(CIVector *a, CIVector *b) {
            return a.X > b.X;
        }];
        
        // Convert from (0, 1) to (0, 255).
        NSMutableArray *convertedPoints = [NSMutableArray arrayWithCapacity:[sortedPoints count]];
        for (NSInteger i = 0; i < points.count; i++){
            CIVector *point = [sortedPoints objectAtIndex:i];
            [convertedPoints addObject:[CIVector vectorWithX:point.X * 255 Y:point.Y * 255]];
        }
        
        
        NSMutableArray *splinePoints = [self splineCurve:convertedPoints];
        
        // If we have a first point like (0.3, 0) we'll be missing some points at the beginning
        // that should be 0.
        CIVector *firstSplinePoint = splinePoints.firstObject;
        
        if (firstSplinePoint.X > 0) {
            for (NSInteger i = firstSplinePoint.X; i >= 0; i--) {
                [splinePoints insertObject:[CIVector vectorWithX:i Y:0] atIndex:0];
            }
        }
        
        // Insert points similarly at the end, if necessary.
        CIVector *lastSplinePoint = splinePoints.lastObject;
        if (lastSplinePoint.X < 255) {
            for (NSInteger i = lastSplinePoint.X + 1; i <= 255; i++) {
                [splinePoints addObject:[CIVector vectorWithX:i Y:255]];
            }
        }
        
        // Prepare the spline points.
        NSMutableArray *preparedSplinePoints = [NSMutableArray arrayWithCapacity:[splinePoints count]];
        for (NSInteger i=0; i<[splinePoints count]; i++)
        {
            CIVector *newPoint = splinePoints[i];
            CIVector *origPoint = [CIVector vectorWithX:newPoint.X Y:newPoint.X];
            float distance = sqrt(pow((origPoint.X - newPoint.X), 2.0) + pow((origPoint.Y - newPoint.Y), 2.0));
            if (origPoint.Y > newPoint.Y)
            {
                distance = -distance;
            }
            [preparedSplinePoints addObject:@(distance)];
        }
        
        [YUCIRGBToneCurveSplineCurveCache() setObject:preparedSplinePoints forKey:points cost:1];
        
        return preparedSplinePoints;
    }
    
    return nil;
}


- (NSMutableArray *)splineCurve:(NSArray *)points
{
    NSMutableArray *sdA = [self secondDerivative:points];
    
    // [points count] is equal to [sdA count]
    NSInteger n = [sdA count];
    if (n < 1)
    {
        return nil;
    }
    double sd[n];
    
    // From NSMutableArray to sd[n];
    for (NSInteger i=0; i<n; i++)
    {
        sd[i] = [[sdA objectAtIndex:i] doubleValue];
    }
    
    
    NSMutableArray *output = [NSMutableArray arrayWithCapacity:(n+1)];
    
    for(NSInteger i = 0; i < n-1 ; i++)
    {
        CIVector *cur = points[i];
        CIVector *next = points[i+1];
        
        for(NSInteger x=cur.X; x < (NSInteger)next.X; x++)
        {
            double t = (double)(x-cur.X)/(next.X-cur.X);
            
            double a = 1-t;
            double b = t;
            double h = next.X-cur.X;
            
            double y= a * cur.Y + b * next.Y + (h * h / 6) * ((a * a * a - a) * sd[i] + (b * b * b - b) * sd[i+1]);
            
            if (y > 255.0) {
                y = 255.0;
            } else if (y < 0.0) {
                y = 0.0;
            }
            [output addObject:[CIVector vectorWithX:x Y:y]];
        }
    }
    
    // The above always misses the last point because the last point is the last next, so we approach but don't equal it.
    [output addObject:points.lastObject];
    return output;
}

- (NSMutableArray *)secondDerivative:(NSArray *)points
{
    const NSInteger n = [points count];
    if ((n <= 0) || (n == 1))
    {
        return nil;
    }
    
    double matrix[n][3];
    double result[n];
    matrix[0][1]=1;
    // What about matrix[0][1] and matrix[0][0]? Assuming 0 for now (Brad L.)
    matrix[0][0]=0;
    matrix[0][2]=0;
    
    for(NSInteger i=1; i<n-1; i++) {
        CIVector *P1 = points[i-1];
        CIVector *P2 = points[i];
        CIVector *P3 = points[i+1];
        
        matrix[i][0]=(double)(P2.X-P1.X)/6;
        matrix[i][1]=(double)(P3.X-P1.X)/3;
        matrix[i][2]=(double)(P3.X-P2.X)/6;
        result[i]=(double)(P3.Y-P2.Y)/(P3.X-P2.X) - (double)(P2.Y-P1.Y)/(P2.X-P1.X);
    }
    
    // What about result[0] and result[n-1]? Assuming 0 for now (Brad L.)
    result[0] = 0;
    result[n-1] = 0;
    
    matrix[n-1][1]=1;
    // What about matrix[n-1][0] and matrix[n-1][2]? For now, assuming they are 0 (Brad L.)
    matrix[n-1][0]=0;
    matrix[n-1][2]=0;
    
    // solving pass1 (up->down)
    for(NSInteger i=1;i<n;i++) {
        double k = matrix[i][0]/matrix[i-1][1];
        matrix[i][1] -= k*matrix[i-1][2];
        matrix[i][0] = 0;
        result[i] -= k*result[i-1];
    }
    
    // solving pass2 (down->up)
    for(NSInteger i=n-2;i>=0;i--) {
        double k = matrix[i][2]/matrix[i+1][1];
        matrix[i][1] -= k*matrix[i+1][0];
        matrix[i][2] = 0;
        result[i] -= k*result[i+1];
    }
    
    double y2[n];
    for(NSInteger i=0; i<n; i++) {
        y2[i]=result[i]/matrix[i][1];
    }
    
    NSMutableArray *output = [NSMutableArray arrayWithCapacity:n];
    for (NSInteger i=0;i<n;i++) {
        [output addObject:@(y2[i])];
    }
    
    return output;
}

@end
