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
    func draw(in view: MTKView) {
        //
    }
    

    @IBOutlet weak var metalView: MTKView!
    
    var context: CIContext!
    var commandQueue: MTLCommandQueue!
    var inputTexture: MTLTexture!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let device = MTLCreateSystemDefaultDevice()!
        self.metalView.device = device
        self.metalView.delegate = self
        self.metalView.framebufferOnly = false
        self.metalView.enableSetNeedsDisplay = true
 
        self.context = CIContext(mtlDevice: device, options: [CIContextOption.workingColorSpace:CGColorSpaceCreateDeviceRGB()])
        self.commandQueue = device.makeCommandQueue()
        
        
        self.inputTexture = try! MTKTextureLoader(device: self.metalView.device!).newTexture(cgImage: UIImage(named: "SampleImage")!.cgImage!, options: nil)
        
        //self.inputTexture = try! MTKTextureLoader(device: self.metalView.device!).newTexture(with: UIImage(named: "SampleImage")!.cgImage!, options: nil)
    }

    func drawInMTKView(view: MTKView) {
        let commandBuffer = self.commandQueue.makeCommandBuffer()
        
        let inputCIImage = CIImage(mtlTexture: inputTexture, options: nil)
        let filter = CIFilter(name: "YUCIHighPassSkinSmoothing")!
        filter.setValue(inputCIImage, forKey: kCIInputImageKey)
        filter.setValue(0.7, forKey: "inputAmount")
        filter.setValue(7.0 * inputCIImage!.extent.width/750.0, forKey: kCIInputRadiusKey)
        let outputCIImage = filter.outputImage!
        
        let cs = CGColorSpaceCreateDeviceRGB()
        let outputTexture = view.currentDrawable?.texture
        self.context.render(outputCIImage, to: outputTexture!,
            commandBuffer: commandBuffer, bounds: outputCIImage.extent, colorSpace: cs)
        commandBuffer?.present(view.currentDrawable!)
        commandBuffer?.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        view.draw()
    }
}

#else

class MetalRenderContextViewController: UIViewController {
    @IBOutlet weak var metalView: UIView!
}

#endif
