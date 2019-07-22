Pod::Spec.new do |s|
  s.name         = "KJPlayer"
  s.version      = "1.0.1"
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

  s.default_subspec  = 'Player' # 默认引入的文件
  s.ios.source_files = 'KJPlayerDemo/KJPlayerHeader.h' # 添加头文件

  s.subspec 'Player' do |y|
    y.source_files = "KJPlayerDemo/Player/**/*.{h,m}" # 添加文件
    y.public_header_files = 'KJPlayerDemo/Player/*.h',"KJPlayerDemo/Player/**/*.h"   # 添加头文件
  end

  s.subspec 'PlayerView' do |a|
    a.source_files = "KJPlayerDemo/PlayerView/**/*.{h,m}" # 添加文件
    a.dependency 'KJPlayer/Player'
  end
  
  s.frameworks = 'Foundation','UIKit','MobileCoreServices','AVFoundation','CommonCrypto','Accelerate'
  
end


