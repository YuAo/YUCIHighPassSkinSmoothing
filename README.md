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

The basic concept/routine of `YUCIHighPassSkinSmoothingFilter` can be described with the following diagram.

[![Routine](http://yuao.github.io/YUCIHighPassSkinSmoothing/docs/filter-routine.jpg)](http://yuao.github.io/YUCIHighPassSkinSmoothing/docs/filter-routine.jpg)

##Consideration

For best effect, you need to create the `CIContext` object with a sRGB working color space instead of the default light-linear color space. You can specify a working color space when creating a context using the `kCIContextWorkingColorSpace` key in the `options` dictionary.

##Usage

##Installation

Either clone the repo and manually add the files in `Sources` directory

or if you use Cocoapods, add the following to your Podfile

	pod 'YUCIHighPassSkinSmoothing'

##Credits

Thanks a lot to [Yien Ma](https://dribbble.com/yien) for providing a lot of suggestions and fine-tunings to the procedure.

##License

YUCIHighPassSkinSmoothing is MIT-licensed. See [LICENSE](https://github.com/YuAo/YUCIHighPassSkinSmoothing/blob/master/LICENSE) file for detail.

Copyright © 2016 Yu Ao
