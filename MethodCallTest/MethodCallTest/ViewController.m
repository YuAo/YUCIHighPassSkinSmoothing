//
//  ViewController.m
//  MethodCallTest
//
//  Created by YuAo on 1/21/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

#import "ViewController.h"

uint64_t dispatch_benchmark(size_t count, void (^block)(void));

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CIVector *v = [CIVector vectorWithX:1.1 Y:1.1];
    uint64_t n = dispatch_benchmark(1000*1000, ^{
        @autoreleasepool {
            [v X];
        }
    });
    NSLog(@"-[NSMutableArray addObject:] : %llu ns", n);
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
