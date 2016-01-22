# YUCIHighPassSkinSmoothing
An implementation of [High Pass Skin Smoothing](https://www.google.com/search?ie=UTF-8&q=photoshop+high+pass+skin+smoothing) using CoreImage.framework

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

You may want to google [High Pass Skin Smoothing](https://www.google.com/search?ie=UTF-8&q=photoshop+high+pass+skin+smoothing) and do the steps in Photoshop or any other image editing software you prefer first before trying to understand the diagram below.

[![Routine](http://yuao.github.io/YUCIHighPassSkinSmoothing/docs/filter-routine.jpg)](http://yuao.github.io/YUCIHighPassSkinSmoothing/docs/filter-routine.jpg)

####The High Pass Filter

There's no `High Pass` filter in CoreImage. Luckily it's not hard to create one (`Photoshop: High Pass` section in the diagram):

> A high-pass filter, if the imaging software does not have one, can be done by duplicating the layer, putting a gaussian blur, inverting, and then blending with the original layer using an opacity (say 50%) with the original layer.
> https://en.wikipedia.org/wiki/High-pass_filter

####Input Parameters



##Consideration

For the best effect, you need to create the `CIContext` object with a sRGB working color space instead of the default light-linear color space. You can specify a working color space when creating a context using the `kCIContextWorkingColorSpace` key in the `options` dictionary.

##Usage

Just use the `YUCIHighPassSkinSmoothingFilter` class.

##Installation

Either clone the repo and manually add the files in `Sources` directory

or if you use Cocoapods, add the following to your Podfile

	pod 'YUCIHighPassSkinSmoothing'

##Credits

Thanks a lot to [Yien Ma](https://dribbble.com/yien) for providing a lot of suggestions and fine-tunings to the procedure.

##License

YUCIHighPassSkinSmoothing is MIT-licensed. See [LICENSE](https://github.com/YuAo/YUCIHighPassSkinSmoothing/blob/master/LICENSE) file for detail.

Copyright © 2016 Yu Ao
