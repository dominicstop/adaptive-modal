
Pod::Spec.new do |s|
  s.name             = 'AdaptiveModal'
  s.version          = '1.2.0'
  s.summary          = 'Config-based UIViewController modal presentation.'

  s.description      = <<-DESC
A library for presenting modal view controllers via a config.
An all-in-one UIKit component for making interactive modals, sheets, drawers, dialogs, and overlays.
Support for gesture-driven animations, and modals that adapt to the current device.
                      DESC

  s.homepage         = 'https://github.com/dominicstop/adaptive-modal'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dominic Go' => 'dominic@dominicgo.dev' }
  s.source           = { :git => 'https://github.com/dominicstop/adaptive-modal.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/GoDominic'

  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/**/*'
  s.frameworks = 'UIKit'
  
  s.dependency 'ComputableLayout', '~> 0.5'
  s.dependency 'DGSwiftUtilities', '~> 0.7'
  
end
