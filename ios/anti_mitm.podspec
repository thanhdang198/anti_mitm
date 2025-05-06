#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_flutter_proxy.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'anti_mitm'
  s.version          = '0.0.1'
  s.summary          = 'device proxy info.'
  s.description      = <<-DESC
device proxy info.
                       DESC
  s.homepage         = 'https://thanhdt.dev'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ThanhDT' => 'contact@thanhdt.dev' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.ios.deployment_target = '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
