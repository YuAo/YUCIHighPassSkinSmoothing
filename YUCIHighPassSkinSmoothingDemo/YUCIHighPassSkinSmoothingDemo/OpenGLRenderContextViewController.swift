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
    
    var image: CIImage!
    
    var startDate: NSDate = NSDate()
    
    var filter = YUCIHighPassSkinSmoothingFilter()
    var inputCIImage = CIImage(CGImage: UIImage(named: "SampleImage")!.CGImage!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredFramesPerSecond = 60;
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()!

        self.context = EAGLContext(API: .OpenGLES2)
        self.ciContext = CIContext(EAGLContext: self.context, options: [kCIContextWorkingColorSpace: colorSpace])
        
        self.glkView.context = self.context
        self.glkView.drawableDepthFormat = .Format24
        
        EAGLContext.setCurrentContext(self.context)
    }
    
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        self.filter.inputImage = self.inputCIImage
        self.filter.inputAmount = abs(sin(NSDate().timeIntervalSinceDate(self.startDate)) * 0.8);
        let outputCIImage = self.filter.outputImage!
        self.image = outputCIImage
        
        self.ciContext.drawImage(self.image, inRect: AVMakeRectWithAspectRatioInsideRect(self.image.extent.size, CGRectApplyAffineTransform(self.view.bounds, CGAffineTransformMakeScale(UIScreen.mainScreen().scale, UIScreen.mainScreen().scale))), fromRect: self.image.extent)
    }
}
