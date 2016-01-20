//
//  DefaultContextViewController.swift
//  YUCIHighPassSkinSmoothingDemo
//
//  Created by YuAo on 1/20/16.
//  Copyright © 2016 YuAo. All rights reserved.
//

import UIKit
import YUCIHighPassSkinSmoothing

class DefaultRenderContextViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sourceImage = UIImage(named: "SampleImage")!
        let inputCIImage = CIImage(CGImage: sourceImage.CGImage!)
        let filter = YUCIHighPassSkinSmoothingFilter()
        filter.inputImage = inputCIImage
        filter.inputAmount = 0.8
        let outputCIImage = filter.outputImage!
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()!
        let context = CIContext(options: [kCIContextWorkingColorSpace: colorSpace])
        let outputCGImage = context.createCGImage(outputCIImage, fromRect: outputCIImage.extent)
        let outputUIImage = UIImage(CGImage: outputCGImage, scale: sourceImage.scale, orientation: sourceImage.imageOrientation)
        
        self.imageView.image = outputUIImage
    }
}
