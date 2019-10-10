# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
inhibit_all_warnings! 
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/zsy78191/Fork-MWFeedParser.git'

target 'rework-reader' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!
  pod 'oc-base'
  pod 'oc-string'
  pod 'oc-date'
#  pod 'oc-net', :podspec => '../../base/oc-net/oc-net.podspec'
  pod 'oc-util'
  pod 'ui-base'
  pod 'ui-util'
  pod 'mvc-base'
#  pod 'mvc-middleware', :podspec => '../../mvc/mvc-middleware/mvc-middleware.podspec'

  #多线程
  pod 'coobjc'

  #RSS解析库
  pod 'Fork-MWFeedParser'
  
  #log框架
#  pod 'CocoaLumberjack'
  
  #相对时间转换工具
  pod 'DateTools'
  
  #图片浏览器
  pod 'Fork-MWPhotoBrowser' 
  
  #img
  pod 'SDWebImage', '~> 4.4.6'
  
  #xml解析
  pod 'KissXML'
  
  #iCloud同步
#  pod 'Ensembles'

  # 网页长图生成
  pod 'TYSnapshotScroll'
 

  # Pods for rework-reader
  target 'rework-readerTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
