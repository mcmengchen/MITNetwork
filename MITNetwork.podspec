Pod::Spec.new do |s|
  s.name             = 'MITNetwork'
  s.version          = '0.0.2'
  s.summary          = 'summary of MITNetwork.'
  s.description      = 'MITNetwork description'
  s.homepage         = 'https://github.com/mcmengchen/MITNetwork'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mcmengchen' => '416922992@qq.com' }
  s.source           = { :git => 'https://github.com/mcmengchen/MITNetwork.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'
  s.source_files = 'MITNetwork/Classes/**/*'
  s.dependency 'AFNetworking'
  s.dependency 'YYCache'
end
