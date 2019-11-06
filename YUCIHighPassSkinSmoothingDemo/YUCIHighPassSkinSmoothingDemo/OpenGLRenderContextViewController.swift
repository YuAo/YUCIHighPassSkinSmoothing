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
    
    var glkView: GLKView! { return (self.view as! GLKView) }
    
    var startDate: NSDate = NSDate()
    
    var filter = YUCIHighPassSkinSmoothing()
    
    var inputCIImage = CIImage(cgImage: UIImage(named: "SampleImage")!.cgImage!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        self.context = EAGLContext(api: .openGLES2)
        self.ciContext = CIContext(eaglContext: self.context, options: [.workingColorSpace: colorSpace])
        self.glkView.context = self.context
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        let amount = abs(sin(NSDate().timeIntervalSince(self.startDate as Date)) * 0.7)
        self.title = String(format: "Input Amount: %.3f", amount)
        self.filter.inputImage = self.inputCIImage
        self.filter.inputAmount = amount as NSNumber
        self.filter.inputRadius = 7.0 * self.inputCIImage.extent.width/750.0 as NSNumber
        self.filter.inputSharpnessFactor = 0
        let outputCIImage = self.filter.outputImage!
        
        self.ciContext.draw(outputCIImage, in: AVMakeRect(aspectRatio: outputCIImage.extent.size, insideRect: self.view.bounds.applying(CGAffineTransform(scaleX: UIScreen.main.scale, y: UIScreen.main.scale))), from: outputCIImage.extent)
    }
}
