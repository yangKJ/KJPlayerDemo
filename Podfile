# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'KJPlayerDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

#  pod 'RealReachability/Ping' # 网络监测
  pod 'IJKMediaFramework'
  
  # DiDi开发工具
  pod 'DoraemonKit/Core', :configurations => ['Debug']
#  pod 'DoraemonKit/WithLoad', :configurations => ['Debug'] # 集成Load耗时检测
  pod 'DoraemonKit/WithMLeaksFinder', :configurations => ['Debug'] # 查找内存泄漏

  # Pods for KJPlayerDemo

  target 'KJPlayerDemoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'KJPlayerDemoUITests' do
    # Pods for testing
  end

end
