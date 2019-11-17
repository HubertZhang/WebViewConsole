#
# Be sure to run `pod lib lint WebViewConsole.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WebViewConsole'
  s.version          = '0.1.0'
  s.summary          = 'Console and ConsoleView for WKWebView'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Display console messages of WKWebView in host app.
                       DESC

  s.homepage         = 'https://github.com/Hubertzhang/WebViewConsole'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Hubertzhang' => 'hubert.zyk@gmail.com' }
  s.source           = { :git => 'https://github.com/Hubertzhang/WebViewConsole.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_versions = '5.0'
  s.ios.deployment_target = '9.0'
  
  s.subspec 'Console' do |sp|
    sp.source_files  = 'WebViewConsole/Console/**/*'
    sp.resource_bundles = {
      'Console' => ['WebViewConsole/Assets/Console/*.*'],
    }
  end
  
  s.subspec 'ConsoleView' do |sp|
    sp.source_files  = 'WebViewConsole/ConsoleView/**/*'
    sp.resource_bundles = {
      'ConsoleView' => ['WebViewConsole/Assets/ConsoleView/*.*'],
    }
    sp.dependency 'RSKGrowingTextView'
  end

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
