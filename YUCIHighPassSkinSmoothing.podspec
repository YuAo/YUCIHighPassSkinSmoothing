Pod::Spec.new do |s|
  s.name         = 'YUCIHighPassSkinSmoothing'
  s.version      = '1.4'
  s.author       = { 'YuAo' => 'me@imyuao.com' }
  s.homepage     = 'https://github.com/YuAo/YUCIHighPassSkinSmoothing'
  s.summary      = 'An implementation of High Pass Skin Smoothing using CoreImage.framework'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.source       = {:git => 'https://github.com/YuAo/YUCIHighPassSkinSmoothing.git', :tag => '1.4'}
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'
  s.source_files = 'Sources/**/*.{h,m}'
  s.resources    = 'Sources/**/*.{png,cikernel}'
  s.dependency  'Vivid'
end
