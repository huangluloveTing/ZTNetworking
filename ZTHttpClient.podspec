Pod::Spec.new do |s|

  s.name         = "ZTHttpClient"
  s.version      = "1.0.2"
  s.summary      = "一个基于AF 的网络框架"

  s.homepage     = "https://github.com/huangluloveTing/ZTHttpClient.git"
  s.license      = 'MIT'
  s.author       = { "Lucky Huang" => "583699255@qq.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/huangluloveTing/ZTHttpClient.git", :tag => s.version}
 
  s.requires_arc = true
 
  s.source_files = 'ZTNetworking/**/*.h' 

    # CACHE
   s.subspec 'Cache' do |cache|

    cache.source_files = 'ZTNetworking/Cache/**/*.{h,m}'
    #cache.dependency 'ZTNetworking/Serializer'
    cache.dependency 'FMDB'

   end

   # HTTP
   s.subspec 'HTTP' do |ht|

    ht.source_files = 'ZTNetworking/HTTP/**/*.{h,m}'
    #ht.dependency 'ZTNetworking/Serializer'
    #ht.dependency 'ZTNetworking/Cache'
    ht.dependency 'AFNetworking'

   end

   # Serializer
   s.subspec 'Serializer' do |se|

    se.source_files = 'ZTNetworking/Serializer/**/*.{h,m}'

   end

end
