//
//  MetalRenderContextViewController.swift
//  YUCIHighPassSkinSmoothingDemo
//
//  Created by YuAo on 1/20/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

import UIKit
import YUCIHighPassSkinSmoothing

#if !(arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
import MetalKit

class MetalRenderContextViewController: UIViewController, MTKViewDelegate {

    @IBOutlet weak var metalView: MTKView!
    
    var context: CIContext!
    var commandQueue: MTLCommandQueue!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let device = MTLCreateSystemDefaultDevice()!
        self.metalView.device = device
        self.metalView.delegate = self
        self.metalView.framebufferOnly = false
        self.metalView.enableSetNeedsDisplay = true
 
        self.context = CIContext(MTLDevice: device, options: [kCIContextWorkingColorSpace:CGColorSpaceCreateDeviceRGB()!])
        self.commandQueue = device.newCommandQueue()
    }

    func drawInMTKView(view: MTKView) {
        let commandBuffer = self.commandQueue.commandBuffer()
        
        let sourceImage = UIImage(named: "SampleImage")!
        let inputCIImage = CIImage(CGImage: sourceImage.CGImage!)
        let filter = YUCIHighPassSkinSmoothingFilter()
        filter.inputImage = inputCIImage
        filter.inputAmount = 0.8
        let outputCIImage = filter.outputImage!
        
        let cs = CGColorSpaceCreateDeviceRGB()!
        let outputTexture = view.currentDrawable?.texture
        self.context.render(outputCIImage, toMTLTexture: outputTexture!,
            commandBuffer: nil, bounds: outputCIImage.extent, colorSpace: cs)
        commandBuffer.presentDrawable(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    func mtkView(view: MTKView, drawableSizeWillChange size: CGSize) {
        view.draw()
    }
    
}

#else

class MetalRenderContextViewController: UIViewController {
    @IBOutlet weak var metalView: UIView!
}

#endif
