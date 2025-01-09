Pod::Spec.new do |s|
  s.name             = 'PopControllerSwift'
  s.version          = '0.1.0'
  s.summary          = 'A short description of PopControllerSwift.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/HeathWang/PopControllerSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'HeathWang' => 'yishu.jay@gmail.com' }
  s.source           = { :git => 'https://github.com/HeathWang/PopControllerSwift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'

  s.source_files = 'PopControllerSwift/Classes/**/*'
  s.frameworks = 'UIKit'
end
