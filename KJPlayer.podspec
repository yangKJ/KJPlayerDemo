Pod::Spec.new do |s|
  s.name         = "KJPlayer"
  s.version      = "2.1.4"
  s.summary      = "KJPlayer play and cache, AVPlayer / MIDIPlayer / IJKPlayer"
  s.homepage     = "https://github.com/yangKJ/KJPlayerDemo"
  s.description  = 'https://github.com/yangKJ/KJPlayerDemo/blob/master/README.md'
  s.license      = "MIT"
  s.license      = "Copyright (c) 2019 yangkejun"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "77" => "ykj310@126.com" }
  s.source       = { :git => "https://github.com/yangKJ/KJPlayerDemo.git", :tag => "#{s.version}" }
  s.social_media_url = 'https://www.jianshu.com/u/c84c00476ab6'
  s.platform     = :ios
  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  s.frameworks = 'Foundation','UIKit'

  s.default_subspec  = 'Common'
  s.ios.source_files = 'KJPlayerDemo/KJPlayerHeader.h' 

  s.subspec 'Common' do |co|
    co.source_files = "KJPlayerDemo/Core/*","KJPlayerDemo/View/*"
    co.resources = "KJPlayerDemo/Core/*.{xcdatamodeld}"
    co.frameworks = 'AVFoundation'
  end

  s.subspec 'AVPlayer' do |av|
    av.source_files = "KJPlayerDemo/KJAVPlayer/*"
    av.dependency 'KJPlayer/Common'
  end
  
  s.subspec 'AVDownloader' do |ad|
    ad.source_files = "KJPlayerDemo/KJAVDownloader/*"
    ad.dependency 'KJPlayer/AVPlayer'
    ad.frameworks = 'MobileCoreServices'
  end
  
  s.subspec 'MIDI' do |md|
    md.source_files = "KJPlayerDemo/KJMidiPlayer/*"
    md.resources = "KJPlayerDemo/KJMidiPlayer/*.{bundle}"
    md.dependency 'KJPlayer/Common'
  end
  
  s.subspec 'IJKPlayer' do |ijk|
    ijk.source_files = "KJPlayerDemo/KJIJKPlayer/*"
    ijk.dependency 'KJPlayer/Common'
  end
  
end
