Pod::Spec.new do |s|

  s.name         = "ZTNetworking"
  s.version      = "1.2.6"
  s.summary      = "一个基于AF 的网络框架"

  s.homepage     = "https://github.com/huangluloveTing/ZTNetworking.git"
  s.license      = 'MIT'
  s.author       = { "Lucky Huang" => "583699255@qq.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/huangluloveTing/ZTNetworking.git", :tag => s.version}
 
  s.requires_arc = true
 
  s.source_files = 'ZTNetworking/ZTNetWorking.h' 

    # CACHE
   s.subspec 'Cache' do |cache|

    cache.source_files = 'ZTNetworking/Cache/**/*.{h,m}'
    cache.dependency 'ZTNetworking/Serializer'
    cache.dependency 'FMDB'

   end

   # HTTP
   s.subspec 'HTTP' do |ht|

    ht.source_files = 'ZTNetworking/HTTP/**/*.{h,m}'
    ht.dependency 'ZTNetworking/Serializer'
    ht.dependency 'ZTNetworking/Cache'
    ht.dependency 'ZTNetworking/Util'
    ht.dependency 'AFNetworking'
    ht.dependency 'Qiniu'

   end

   # Serializer
   s.subspec 'Serializer' do |se|

    se.source_files = 'ZTNetworking/Serializer/**/*.{h,m}'

   end

   # Util
   s.subspec 'Util' do |util|

    util.source_files = 'ZTNetworking/Util/**/*'

   end

   # 提交命令
   # 语法验证
   # pod spec lint ZTNetworking.podspec --use-libraries --allow-warnings --verbose
   # 提交 
   # pod trunk push ZTNetworking.podspec --use-libraries --allow-warnings --verbose

end
