Pod::Spec.new do |s|
  s.name         = 'YUCIHighPassSkinSmoothing'
  s.version      = '1.0'
  s.author       = { 'YuAo' => 'me@imyuao.com' }
  s.homepage     = 'https://yuao.me'
  s.summary      = 'An implementation of High Pass Skin Smoothing using CoreImage.framework'
  s.source       = {:git => 'https://github.com/YuAo/YUCIHighPassSkinSmoothing.git'}
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.source_files = 'Sources/**/*.{h,m}'
  s.resources    = 'Sources/**/*.{png,cikernel}'
end
