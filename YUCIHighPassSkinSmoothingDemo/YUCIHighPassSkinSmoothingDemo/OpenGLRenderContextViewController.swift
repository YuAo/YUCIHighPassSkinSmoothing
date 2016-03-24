//
//  OpenGLRenderContextViewController.swift
//  YUCIHighPassSkinSmoothingDemo
//
//  Created by YuAo on 1/20/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

import UIKit
import GLKit
import YUCIHighPassSkinSmoothing
import AVFoundation

class OpenGLRenderContextViewController: GLKViewController {
    
    var context : EAGLContext!
    var ciContext : CIContext!
    
    var glkView: GLKView! { return self.view as! GLKView }
    
    var startDate: NSDate = NSDate()
    
    var filter = YUCIHighPassSkinSmoothing()
    
    var inputCIImage = CIImage(CGImage: UIImage(named: "SampleImage")!.CGImage!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let colorSpace = CGColorSpaceCreateDeviceRGB()!
        self.context = EAGLContext(API: .OpenGLES2)
        self.ciContext = CIContext(EAGLContext: self.context, options: [kCIContextWorkingColorSpace: colorSpace])
        self.glkView.context = self.context
    }
    
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        let amount = abs(sin(NSDate().timeIntervalSinceDate(self.startDate)) * 0.7)
        self.title = String(format: "Input Amount: %.3f", amount)
        self.filter.inputImage = self.inputCIImage
        self.filter.inputAmount = amount
        self.filter.inputRadius = 7.0 * self.inputCIImage.extent.width/750.0
        self.filter.inputSharpnessFactor = 0
        let outputCIImage = self.filter.outputImage!
        self.ciContext.drawImage(outputCIImage, inRect: AVMakeRectWithAspectRatioInsideRect(outputCIImage.extent.size, CGRectApplyAffineTransform(self.view.bounds, CGAffineTransformMakeScale(UIScreen.mainScreen().scale, UIScreen.mainScreen().scale))), fromRect: outputCIImage.extent)
    }
}
