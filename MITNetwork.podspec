Pod::Spec.new do |s|
  s.name             = 'MITNetwork'
  s.version          = '0.1.0'
  s.summary          = 'A short description of MITNetwork.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/mcmengchen/MITNetwork'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mcmengchen' => '416922992@qq.com' }
  s.source           = { :git => 'https://github.com/mcmengchen/MITNetwork.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'MITNetwork/Classes/**/*'
  s.dependency 'AFNetworking','YYCache'
end
