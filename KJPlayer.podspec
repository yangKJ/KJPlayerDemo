Pod::Spec.new do |s|
  s.name         = "KJPlayer"
  s.version      = "2.1.4"
  s.summary      = "KJPlayer play and cache, AVPlayer / MIDIPlayer / IJKPlayer"
  s.homepage     = "https://github.com/yangKJ/KJPlayerDemo"
  s.description  = 'https://github.com/yangKJ/KJPlayerDemo/blob/master/README.md'
  s.license      = "MIT"
  s.license      = "Copyright (c) 2019 yangkejun"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.source       = { :git => "https://github.com/yangKJ/KJPlayerDemo.git", :tag => "#{s.version}" }
  s.platform     = :ios
  s.requires_arc = true
  s.static_framework = true
  
  s.ios.deployment_target = '9.0'
  s.frameworks = 'Foundation', 'UIKit', 'AVFoundation', 'MediaPlayer'

  s.default_subspec  = 'AVPlayer/AVCore'
  s.ios.source_files = 'KJPlayerDemo/KJPlayerHeader.h' 

  s.subspec 'Common' do |co|
    co.source_files = "KJPlayerDemo/Core/*.{h,m}","KJPlayerDemo/View/*.{h,m}"
    co.resources = "KJPlayerDemo/Core/*.{xcdatamodeld}"
    
#    co.subspec 'Core' do |xx|
#      xx.source_files = "KJPlayerDemo/Core/*.{h,m}"
#      xx.resources = "KJPlayerDemo/Core/*.{xcdatamodeld}"
#    end
#    co.subspec 'View' do |xx|
#      xx.source_files = "KJPlayerDemo/View/*.{h,m}"
#      xx.dependency 'KJPlayer/Common/Core'
#    end
  end

  s.subspec 'AVPlayer' do |av|
    av.subspec 'AVCore' do |xx|
      xx.source_files = "KJPlayerDemo/KJAVPlayer/*.{h,m}"
      xx.dependency 'KJPlayer/Common'
    end
    av.subspec 'AVDownloader' do |xx|
      xx.source_files = "KJPlayerDemo/KJAVPlayer/KJAVDownloader/**/*"
      xx.frameworks = 'MobileCoreServices'
      xx.dependency 'KJPlayer/AVPlayer/AVCore'
    end
  end
  
  s.subspec 'MIDI' do |md|
    md.source_files = "KJPlayerDemo/KJMidiPlayer/*.{h,m}"
    md.resources = "KJPlayerDemo/KJMidiPlayer/*.{bundle}"
    md.dependency 'KJPlayer/Common'
  end
  
  s.subspec 'IJKPlayer' do |jk|
    jk.source_files = "KJPlayerDemo/KJIJKPlayer/*.{h,m}"
    jk.dependency 'KJPlayer/Common'
#    jk.dependency 'KJExceedSDK'
  end
  
  s.author = { "77" => "ykj310@126.com" }
  s.social_media_url = "https://juejin.cn/user/1987535102554472/posts"
  
end
