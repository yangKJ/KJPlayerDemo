Pod::Spec.new do |s|
  s.name         = "KJPlayer"
  s.version      = "1.0.6"
  s.summary      = "A good player made by yangkejun"
  s.homepage     = "https://github.com/yangKJ/KJPlayerDemo"
  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.license      = "Copyright (c) 2019 yangkejun"
  s.author       = { "77" => "393103982@qq.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/yangKJ/KJPlayerDemo.git", :tag => "#{s.version}" }
  s.social_media_url = 'https://www.jianshu.com/u/c84c00476ab6'
  s.requires_arc = true
  s.ios.deployment_target = '9.0'

  s.ios.source_files = 'KJPlayerDemo/KJPlayerHeader/*.h' # 添加头文件
  s.default_subspec  = 'KJPlayer' # 默认

  s.subspec 'KJPlayer' do |y|
    y.source_files = "KJPlayerDemo/KJPlayer/**/*.{h,m}"
    y.public_header_files = 'KJPlayerDemo/KJPlayer/*.h',"KJPlayerDemo/KJPlayer/**/*.h"
    y.frameworks = 'Foundation','UIKit','MobileCoreServices','AVFoundation'
  end

  s.subspec 'KJPlayerView' do |a|
    a.source_files = "KJPlayerDemo/KJPlayerView/*.{h,m}" # 添加文件
    a.public_header_files = 'KJPlayerDemo/KJPlayerView/*.h'
    a.resources = "KJPlayerDemo/KJPlayerView/*.{bundle}" # 添加数据资料
    a.dependency 'KJPlayer/KJPlayer'
    a.frameworks = 'QuartzCore','Accelerate','CoreGraphics'
  end

end


