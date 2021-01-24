Pod::Spec.new do |s|
  s.name         = "KJPlayer"
  s.version      = "1.0.9"
  s.summary      = "A good player made by yangkejun"
  s.homepage     = "https://github.com/yangKJ/KJPlayerDemo"
  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.license      = "Copyright (c) 2019 yangkejun"
  s.author       = { "77" => "ykj310@126.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/yangKJ/KJPlayerDemo.git", :tag => "#{s.version}" }
  s.social_media_url = 'https://www.jianshu.com/u/c84c00476ab6'
  s.requires_arc = true
  s.ios.deployment_target = '9.0'

  s.default_subspec  = 'KJPlayer'
  s.ios.source_files = 'KJPlayerDemo/KJPlayerHeader.h' 

  s.subspec 'KJPlayer' do |y|
    y.source_files = "KJPlayerDemo/Core/*.{h,m}","KJPlayerDemo/KJPlayer/*.{h,m}"
    y.public_header_files = 'KJPlayerDemo/Core/*.h','KJPlayerDemo/KJPlayer/*.h'
    y.frameworks = 'MobileCoreServices','AVFoundation'
  end

  s.subspec 'KJPlayerView' do |a|
    a.source_files = "KJPlayerDemo/KJPlayerView/*.{h,m}" 
    a.public_header_files = 'KJPlayerDemo/KJPlayerView/*.h'
    a.resources = "KJPlayerDemo/KJPlayerView/*.{bundle}" 
    a.frameworks = 'QuartzCore','Accelerate','CoreGraphics'
    a.dependency 'KJPlayer/KJPlayer'
  end
  
  s.frameworks = 'Foundation','UIKit'

end


