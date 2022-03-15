Pod::Spec.new do |s|
  s.name         = "KJPlayer"
  s.version      = "2.1.12"
  s.summary      = "KJPlayer play and cache, AVPlayer / MIDIPlayer / IJKPlayer"
  s.homepage     = "https://github.com/yangKJ/KJPlayerDemo"
  s.description  = 'https://github.com/yangKJ/KJPlayerDemo/blob/master/README.md'
  s.license      = "Copyright (c) 2019 yangkejun"
  s.author       = { "77" => "ykj310@126.com" }
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.source       = { :git => "https://github.com/yangKJ/KJPlayerDemo.git", :tag => "#{s.version}" }
  s.social_media_url = "https://juejin.cn/user/1987535102554472/posts"
  s.platform     = :ios
  s.requires_arc = true
  s.static_framework = true
  
  s.ios.deployment_target = '9.0'
  s.frameworks = 'Foundation', 'UIKit', 'AVFoundation', 'MediaPlayer'

  s.ios.source_files = 'Sources/KJPlayerHeader.h'

  s.subspec 'Common' do |xx|
    xx.source_files = "Sources/Core/*.{h,m}"
  end

  s.subspec 'AVPlayer' do |av|
    av.subspec 'AVCore' do |xx|
      xx.source_files = "Sources/AVPlayer/*.{h,m}"
      xx.dependency 'KJPlayer/Common'
    end
    av.subspec 'AVDownloader' do |xx|
      xx.source_files = "Sources/AVPlayer/AVDownloader/**/*"
      xx.frameworks = 'MobileCoreServices'
      xx.dependency 'KJPlayer/AVPlayer/AVCore'
      xx.dependency 'KJPlayer/Database'
      xx.dependency 'KJPlayer/Downloader'
    end
  end
  
  s.subspec 'MIDI' do |md|
    md.source_files = "Sources/MidiPlayer/*.{h,m}"
    md.resources = "Sources/MidiPlayer/*.{bundle}"
    md.dependency 'KJPlayer/Common'
  end
  
  s.subspec 'IJKPlayer' do |jk|
    jk.source_files = "Sources/IJKPlayer/*.{h,m}"
    jk.dependency 'KJPlayer/Common'
    jk.dependency 'IJKMediaFramework'
    jk.libraries = 'c++', 'z', 'bz2', 'iconv'
    jk.ios.deployment_target = '9.0'
    jk.pod_target_xcconfig  = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    jk.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  end
  
  ## UI控件模块
  s.subspec 'CustomView' do |xx|
    xx.source_files = "Sources/View/*.{h,m}"
    xx.resource_bundles = {
      'KJPlayer' => ['Sources/View/*.{ttf}']
    }
    xx.dependency 'KJPlayer/Common'
  end

  ## 数据库模块
  s.subspec 'Database' do |db|
    db.source_files = "Sources/Tools/Database/*.{h,m}"
    db.resources = "Sources/Tools/Database/*.{xcdatamodeld}"
  end
  
  ## 缓存模块
  s.subspec 'Cache' do |xx|
    xx.source_files = "Sources/Tools/Cache/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
    xx.dependency 'KJPlayer/Database'
  end
  
  ## 下载模块
  s.subspec 'Downloader' do |xx|
    xx.source_files = "Sources/Tools/Downloader/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
  end
  
  ## 动态切换内核
  s.subspec 'DynamicSource' do |xx|
    xx.source_files = "Sources/Tools/DynamicSource/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
  end
  
  ## 心跳包
  s.subspec 'PingTimer' do |xx|
    xx.source_files = "Sources/Tools/PingTimer/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
  end
  
  ## 记录播放时间
  s.subspec 'RecordTime' do |xx|
    xx.source_files = "Sources/Tools/RecordTime/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
    xx.dependency 'KJPlayer/Database'
  end
  
  ## 跳过片头片尾
  s.subspec 'SkipTime' do |xx|
    xx.source_files = "Sources/Tools/SkipTime/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
  end
  
  ## 尝试观看
  s.subspec 'TryTime' do |xx|
    xx.source_files = "Sources/Tools/TryTime/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
  end
  
  ## 截屏板块
  s.subspec 'Screenshots' do |xx|
    xx.source_files = "Sources/Tools/Screenshots/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
    xx.dependency 'KJPlayer/Database'
  end
  
  ## 前后台功能
  s.subspec 'BackgroundMonitoring' do |xx|
    xx.source_files = "Sources/Tools/BackgroundMonitoring/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
  end
  
end
