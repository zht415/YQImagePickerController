platform :ios, '8.0'
use_frameworks!

target 'YQImagePickerController' do
    
  pod 'AFNetworking'
  pod 'MJRefresh'
  pod 'SDWebImage'
  pod 'MBProgressHUD'
  pod 'FMDB'
  pod 'JSONModel’
  pod 'UMengAnalytics'
  pod 'AliyunOSSiOS'
  pod 'SDCycleScrollView'
  pod 'YYModel'
  pod 'FreeStreamer'
  pod 'Masonry', '~> 1.1.0'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end


