
Pod::Spec.new do |s|
  s.name             = 'AdaptiveModal'
  s.version          = '0.1.0'
  s.summary          = 'TBA'

  s.description      = <<-DESC
TBA
                      DESC

  s.homepage         = 'https://github.com/dominicstop/AdaptiveModal'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dominic Go' => 'dominic@dominicgo.dev' }
  s.source           = { :git => 'https://github.com/dominicstop/AdaptiveModal.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/@GoDominic'

  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'AdaptiveModal/Sources/**/*'
  s.frameworks = 'UIKit'
  s.dependency 'ComputableLayout', '0.4.0'
end
