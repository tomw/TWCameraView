#
# Be sure to run `pod lib lint TWCameraView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TWCameraView'
  s.version          = '1.1.0'
  s.summary          = 'Simple & easy-to-use Swift camera view for iOS.'

  s.homepage         = 'https://github.com/tomw/TWCameraView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tom Weightman' => 'hi@tomweightman.com' }
  s.source           = { :git => 'https://github.com/tomw/TWCameraView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.requires_arc = true
  s.ios.deployment_target = '10.0'

  s.source_files = 'TWCameraView/*.swift'
  s.pod_target_xcconfig =  {
        'SWIFT_VERSION' => '3.0',
  }

  # s.resource_bundles = {
  #   'TWCameraView' => ['TWCameraView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
