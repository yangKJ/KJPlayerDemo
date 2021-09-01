Pod::Spec.new do |s|
  s.name         = "KJPlayer"
  s.version      = "2.1.6"
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
  
  s.ios.deployment_target = '10.0'
  s.frameworks = 'Foundation', 'UIKit', 'AVFoundation', 'MediaPlayer'

  s.default_subspec  = 'AVPlayer/AVCore'
  s.ios.source_files = 'PlayerSource/KJPlayerHeader.h' 

  s.subspec 'Common' do |xx|
    xx.source_files = "PlayerSource/Core/*.{h,m}"
  end

  s.subspec 'AVPlayer' do |av|
    av.subspec 'AVCore' do |xx|
      xx.source_files = "PlayerSource/KJAVPlayer/*.{h,m}"
      xx.dependency 'KJPlayer/Common'
    end
    av.subspec 'AVDownloader' do |xx|
      xx.source_files = "PlayerSource/KJAVPlayer/KJAVDownloader/**/*"
      xx.frameworks = 'MobileCoreServices'
      xx.dependency 'KJPlayer/AVPlayer/AVCore'
      xx.dependency 'KJPlayer/Database'
    end
  end
  
  s.subspec 'MIDI' do |md|
    md.source_files = "PlayerSource/KJMidiPlayer/*.{h,m}"
    md.resources = "PlayerSource/KJMidiPlayer/*.{bundle}"
    md.dependency 'KJPlayer/Common'
  end
  
  s.subspec 'IJKPlayer' do |jk|
    jk.source_files = "PlayerSource/KJIJKPlayer/*.{h,m}"
    jk.dependency 'KJPlayer/Common'
    jk.dependency 'IJKMediaFramework'
    jk.libraries = 'c++', 'z', 'bz2', 'iconv'
    jk.pod_target_xcconfig  = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    jk.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  end

  s.subspec 'Database' do |db|
    db.source_files = "PlayerSource/Function/Database/*.{h,m}"
    db.resources = "PlayerSource/Function/Database/*.{xcdatamodeld}"
  end
  
  s.subspec 'Cache' do |xx|
    xx.source_files = "PlayerSource/Function/Cache/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
    xx.dependency 'KJPlayer/Database'
  end
  
  s.subspec 'CustomView' do |xx|
    xx.source_files = "PlayerSource/View/*.{h,m}"
    xx.resource_bundles = {
      'KJPlayer' => ['PlayerSource/View/*.{ttf}']
    }
    xx.dependency 'KJPlayer/Common'
  end
  
  # 动态切换内核
  s.subspec 'DynamicSource' do |xx|
    xx.source_files = "PlayerSource/Function/DynamicSource/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
  end
  
  # 心跳包
  s.subspec 'PingTimer' do |xx|
    xx.source_files = "PlayerSource/Function/PingTimer/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
  end
  
  # 记录播放时间
  s.subspec 'RecordTime' do |xx|
    xx.source_files = "PlayerSource/Function/RecordTime/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
    xx.dependency 'KJPlayer/Database'
  end
  
  # 跳过片头片尾
  s.subspec 'SkipTime' do |xx|
    xx.source_files = "PlayerSource/Function/SkipTime/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
  end
  
  # 尝试观看
  s.subspec 'TryTime' do |xx|
    xx.source_files = "PlayerSource/Function/TryTime/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
  end
  
  # 截屏板块
  s.subspec 'Screenshots' do |xx|
    xx.source_files = "PlayerSource/Function/Screenshots/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
    xx.dependency 'KJPlayer/Database'
  end
  
  # 前后台功能
  s.subspec 'BackgroundMonitoring' do |xx|
    xx.source_files = "PlayerSource/Function/BackgroundMonitoring/*.{h,m}"
    xx.dependency 'KJPlayer/Common'
  end
  
end
