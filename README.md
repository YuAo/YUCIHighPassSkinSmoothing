# YUCIHighPassSkinSmoothing
An implementation of [High Pass Skin Smoothing](https://www.google.com/search?ie=UTF-8&q=photoshop+high+pass+skin+smoothing) using CoreImage.framework

##Previews

![Preview 1](http://yuao.github.io/YUCIHighPassSkinSmoothing/previews/1.jpg)

![Preview 2](http://yuao.github.io/YUCIHighPassSkinSmoothing/previews/2.jpg)

![Preview 3](http://yuao.github.io/YUCIHighPassSkinSmoothing/previews/3.jpg)

![Preview 4](http://yuao.github.io/YUCIHighPassSkinSmoothing/previews/4.jpg)

##Performance

##Concepts

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
