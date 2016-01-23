# YUCIHighPassSkinSmoothing

An implementation of [High Pass Skin Smoothing](https://www.google.com/search?ie=UTF-8&q=photoshop+high+pass+skin+smoothing) using CoreImage.framework

Available on both OS X and iOS.

##Previews

![Preview 1](http://yuao.github.io/YUCIHighPassSkinSmoothing/previews/1.jpg)

![Preview 2](http://yuao.github.io/YUCIHighPassSkinSmoothing/previews/2.jpg)

![Preview 3](http://yuao.github.io/YUCIHighPassSkinSmoothing/previews/3.jpg)

![Preview 4](http://yuao.github.io/YUCIHighPassSkinSmoothing/previews/4.jpg)

##Performance

Tests are made in Instruments with the "OpenGL ES Analysis" template. 

The `CIContext` object is created with `EAGLContext` and a sRGB working color space (`CGColorSpaceCreateDeviceRGB()`).

```
Image Size: 640 x 800
Input Radius: 7.0
Operation System: iOS 9

Device: iPhone 5s / FPS: 60
Device: iPhone 5  / FPS: ~24
```

##Concepts

The basic routine of `YUCIHighPassSkinSmoothingFilter` can be described with the following diagram.

[![Routine](http://yuao.github.io/YUCIHighPassSkinSmoothing/docs/filter-routine.jpg)](http://yuao.github.io/YUCIHighPassSkinSmoothing/docs/filter-routine.jpg)

####Basic Concept

The main theory behind `High Pass Skin Smoothing` is `Frequency Separation`.

Frequency separation splits up the tones and colors of a image from its more detailed textures. It is possible because a digital image can be interpreted as different frequencies represented as sine waves.

> High frequencies in an image will contain information about fine details, such as skin pores, hair, fine lines, skin imperfections.

> Low frequencies are the image data that contains information about volume, tone and color transitions. In other words: shadows and light areas, colors and tones.

> https://fstoppers.com/post-production/ultimate-guide-frequency-separation-technique-8699

By using [High Pass](https://en.wikipedia.org/wiki/High-pass_filter) filter, the image can be separated into high and low spatial frequencies. Then we will be able to smoothing the image while preseving a fine level of detail by applying adjustments (`Curve Adjustment` in the diagram) to certain frequencies of the image.

####High Pass Filter

There's no `High Pass` filter in CoreImage. Luckily it's not hard to create one (`High Pass Filter` section in the diagram):

```
highpass.rgb = image.rgb - gaussianBlurredImage.rgb + vec3(0.5,0.5,0.5)
```

####Mask Generating

A mask image is generated using high pass filter (Green and blue channel overlay blend -> high pass -> hard light blend X 3) for separating the parts of the image which need to be adjusted from the ones that should remain untouched.

This mask image is then used in `Blend with Mask (CIBlendWithMask)` filter to blend the adjusted image with the untouched one to produce the final output image.

#####Improvements

Besides the steps in the diagram, `YUCIHighPassSkinSmoothing` actually has two more steps.

The exposure of the input image is decreased by 1 EV before being sent to the `Mask Generating Routine` (in `-[YUCIHighPassDermabrasionRangeSelectionFilter outputImage]` method) and a RGB curve adjustment is added to the mask at the end of the `Mask Generating Routine` (at the end of `YUCIDermabrasionHardLightFilter.cikernel`).

These steps can make the result better on the areas with high brightness. The whole process can of corse work without these two steps.

####Input Parameters

`inputAmount`: A number value that controls the intensity of the `Curve Adjustment` step and the sharpness of the final `Sharpen` step. You use this value to control the overall filter strength. Valid from `0` to `1.0`. The default value is `0.75`.

`inputControlPoints`: A array of `CIVector` that defines the control points of the curve in `Curve Adjustment` step. The default value of this parameter is `[(0,0), (120/255.0,146/255.0), (1,1)]`.

`inputRadius`: A number value that controls the radius (in pixel) of `High Pass` filter. The default value of this parameter is `8.0`. Try adjusting this value according to the resolution of the input image and the level of detail you want to preserve.

##Consideration

For the best effect, you need to create the `CIContext` object with a sRGB working color space instead of the default light-linear color space. You can specify a working color space when creating a context using the `kCIContextWorkingColorSpace` key in the `options` dictionary.

##Usage

Use the `YUCIHighPassSkinSmoothingFilter`, like any other built in core image filters.

On iOS 9 or later, you can use `CIFilter(name: "YUCIHighPassSkinSmoothingFilter")`

`YUCIHighPassFilter` and `YUCIRGBToneCurveFilter` can also be used directly if you need them.

##Installation

Either clone the repo and manually add the files in `Sources` directory

or if you use Cocoapods, add the following to your Podfile

	pod 'YUCIHighPassSkinSmoothing'


##Credits

Thanks a lot to [Yien Ma](https://dribbble.com/yien) for providing a lot of suggestions and fine-tunings to the procedure.

##License

YUCIHighPassSkinSmoothing is MIT-licensed. See [LICENSE](https://github.com/YuAo/YUCIHighPassSkinSmoothing/blob/master/LICENSE) file for detail.

Copyright © 2016 [Yu Ao](https://yuao.me)
